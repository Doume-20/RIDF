const { spawn } = require('child_process');
const { join } = require('path');
const util = require('util');
const Package = require('./package.js');

function directory() {
    try {
        return __dirname;
    } catch {
        return process.cwd();
    }
}

class DefaultExecutor {
    constructor(options = null, encoding = 'utf8') {
        this.options = options ?? { env: process.env, cwd: directory() };
        this.encoding = encoding;
    }

    execute(command, args = [], env = {}) {
        return new Promise((resolve, reject) => {
            let stdout = Buffer.alloc(0);
            let stderr = Buffer.alloc(0);

            const options = {
                ...this.options,
                env: {
                    ...(this.options.env ?? {}),
                    ...(env ?? {})
                },
                stdio: [null, 'pipe', 'pipe']
            }
            const child = spawn(command, args, options);

            child.stdout.on('data', data => stdout = data ? Buffer.concat([stdout, data]) : stdout);
            child.stderr.on('data', data => stderr = data ? Buffer.concat([stderr, data]) : stderr);

            child.on('error', error => reject(error));
            child.on('exit', code => {
                const result = {
                    code,
                    output: stdout.toString(this.encoding),
                    error: stderr.toString(this.encoding)
                };

                return resolve(result);
            });
        });
    }
}

class SessionExecutor {
    constructor(executor, system = false, hidden = true) {
        this.executor = executor;
        this.system = system;
        this.hidden = hidden;
    }

    get host() {
        return `${process.env.ProgramFiles}\\Unowhy\\HiSqool Manager\\sqoolctl\\sqoolctl.exe`;
    }

    execute(command, args = [], env = {}) {
        const system = this.system ? ['--system'] : [];
        const hidden = this.hidden ? ['--hidden'] : [];

        return this.executor.execute(this.host, ['asuser', '--modern', '--wait', ...system, ...hidden, '--working-dir', directory(), '--variables', JSON.stringify(Object.keys(env)), command, ...args], env);
    }
}

class CommandEngine {
    constructor(executor) {
        this.executor = executor;
    }

    get host() {
        return process.env.ComSpec;
    }

    executeScript(script, args) {
        const env = {
            EXECUTION_SCRIPT: script,
            EXECUTION_ARGUMENTS: JSON.stringify(args)
        };

        return this.executor.execute(this.host, ['/C', `(chcp 65001 > nul 2>&1) & (cmd /C %EXECUTION_SCRIPT%)`], env);
    }

    executeFile(file, args) {
        return this.executeScript(`"${join(directory(), file)}" %EXECUTION_ARGUMENTS%`, args);
    }

    executeProgram(command, args = [], env = {}) {
        return this.executor.execute(command, args, env);
    }
}

class PowerShellEngine {
    constructor(command) {
        this.command = command;
    }

    get host() {
        return `${process.env.windir}\\System32\\WindowsPowerShell\\v1.0\\powershell.exe`;
    }

    executeScript(script, args) {
        script = `$ErrorActionPreference = 'Stop' ; $ProgressPreference = 'SilentlyContinue' ; $OutputEncoding = [System.Text.Encoding]::UTF8 ; ${script}`;

        // Do not use -EncodedCommand because it changes the error output format to XML when NonInteractive is used
        const encoded = Buffer.from(script, 'utf16le').toString('base64');
        const execute = `Invoke-Expression ([System.Text.Encoding]::Unicode.GetString([Convert]::FromBase64String('${encoded}')))`;

        script = `${this.host} -NoProfile -NoLogo -NonInteractive -ExecutionPolicy Unrestricted "${execute}"`;

        return this.command.executeScript(script, args);
    }

    executeFile(file, args) {
        if (Array.isArray(args)) {
            return this.executeScript(`$parsed = ConvertFrom-Json $env:EXECUTION_ARGUMENTS ; & "${join(directory(), file)}" @parsed ; exit $LASTEXITCODE`, args);
        }
        else {
            return this.executeScript(`$parsed = (ConvertFrom-Json $env:EXECUTION_ARGUMENTS).PSObject.Properties | ForEach-Object -Begin { $r = @{} } -Process { $r[$_.Name] = $_.Value } -End { $r } ; & "${join(directory(), file)}" @parsed ; exit $LASTEXITCODE`, args);
        }
    }

    executeProgram(command, args = [], env = {}) {
        return this.command.executeProgram(command, args, env);
    }
}

class LoggedEngine {
    constructor(logger, engine) {
        this.logger = logger;
        this.engine = engine;
    }

    async executeScript(script, args, title) {
        try {
            this.logRequest(title, 'script', script, args);

            const result = await this.engine.executeScript(script, args);

            this.logResult(title, result);

            return result;
        } catch (error) {
            this.logger.error(error);
            throw error;
        }
    }

    async executeFile(file, args, title) {
        try {
            this.logRequest(title, 'file', file, args);

            const result = await this.engine.executeFile(file, args);

            this.logResult(title, result);

            return result;
        } catch (error) {
            this.logger.error(error);
            throw error;
        }
    }

    async executeProgram(command, args, env, title) {
        try {
            this.logRequest(title, 'program', command, args, env);

            const result = await this.engine.executeProgram(command, args, env);

            this.logResult(title, result);

            return result;
        } catch (error) {
            this.logger.error(error);
            throw error;
        }
    }

    logRequest(title, type, source, args, env) {
        this.logger.log(`${title} - Executing ${type} (${source})...`);
        if (args) {
            this.logger.log(`${title} - Arguments: ${JSON.stringify(args)}`);
        }
        if (env) {
            this.logger.log(`${title} - Environment: ${JSON.stringify(env)}`);
        }
    }

    logResult(title, result) {
        if (result.output) {
            this.logger.log(`${title} - Output: ${result.output}`);
        }
        if (result.error) {
            this.logger.error(`${title} - Error: ${result.error}`);
        }
        this.logger.log(`${title} - Code: ${result.code}`);
    }
}

class Execution {
    constructor(context) {
        this.context = context;
    }

    interactive(system = false, hidden = true) {
        const command = new CommandEngine(new SessionExecutor(new DefaultExecutor(), system, hidden));
        const powershell = new PowerShellEngine(command);

        return new LoggedEngine(this.logger, powershell);
    }

    service() {
        const command = new CommandEngine(new DefaultExecutor());
        const powershell = new PowerShellEngine(command);

        return new LoggedEngine(this.logger, powershell);
    }

    get metadata() {
        return this.context.metadata;
    }

    get trigger() {
        return this.context.trigger;
    } 

    get name() {
        return this.context.scriptName;
    }

    get device() {
        return this.context.deviceId;
    }

    get logger() {
        return this.context.logger;
    }

    get application() {
        return global.nestApp;
    }

    get version() {
        try {
            return this.application.get('ConfigurationService').buildVersion.packageVersion ?? "0.0.0";
        } catch {
            return "0.0.0";
        }
    }
}

class FormatLogger {
    constructor(logger) {
        this.logger = logger;
    }

    error(message, trace, context) {
        this.logger.error(util.format(message), trace, context);
    }

    log(message, context) {
        this.logger.log(util.format(message), context);
    }

    warn(message, context) {
        this.logger.warn(util.format(message), context);
    }

    debug(message, context) {
        this.logger.debug(util.format(message), context);
    }

    verbose(message, context) {
        this.logger.verbose(util.format(message), context);
    }
}

class Runner {
    constructor(context) {
        this.context = {
            ...context,
            logger: new FormatLogger(context.logger)
        };
        this.package = new Package();
    }

    async check(options) {
        try {
            this.context.logger.log(`Checking ${this.context.scriptName} (${this.context.trigger})`);
            const execution = new Execution(this.context);
            return await this.package.evaluate(execution, options);
        } catch (error) {
            this.context.logger.error(error);
            return false;
        }
    }

    async perform(options) {
        try {
            this.context.logger.log(`Applying ${this.context.scriptName} (${this.context.trigger})`);
            const execution = new Execution(this.context);
            await this.package.execute(execution, options);
            return true;
        } catch (error) {
            this.context.logger.error(error);
            return false;
        }
    }
}

module.exports = Runner;