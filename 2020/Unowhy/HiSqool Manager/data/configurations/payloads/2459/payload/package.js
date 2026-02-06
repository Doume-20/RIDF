class Package {
    engine(execution, options) {
        if (!options.engine) {
            return execution.service();
        }

        switch (options.engine.toLowerCase()) {
            case 'service':
                return execution.service();

            case 'interactive':
                return execution.interactive(true, true);

            case 'user':
                return execution.interactive(false, true);
        }

        throw `Unknown engine: ${options.engine}`;
    }

    async evaluate(execution, options) {
        if (!options.script) {
            return false;
        }

        const engine = this.engine(execution, options);
        const result = await engine.executeFile('Evaluate.ps1', [options.script], 'Verify script signature');

        return result.code === 0; // Whether to execute
    }

    async execute(execution, options) {
        if (!options.script) {
            return;
        }

        const engine = this.engine(execution, options);
        await engine.executeFile('Execute.ps1', [options.script], 'Execute script');
    }
}

module.exports = Package;