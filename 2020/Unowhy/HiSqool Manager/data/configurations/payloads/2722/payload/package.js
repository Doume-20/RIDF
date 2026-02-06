class Package {
    async evaluate(execution, options) {
        const engine = execution.service();

        const result = await engine.executeFile('Evaluate.ps1', [execution.metadata.software.version], 'Verify Drive Monlycée.net version');

        return result.code !== 0; // Whether to execute
    }

    async execute(execution, options) {
        await this.install(execution);
    }

    async install(execution) {
        const engine = execution.service();

        const result = await engine.executeFile('Execute.ps1', [], 'Install Drive Monlycée.net binaries');

        if (result.code !== 0)
            throw "Could not install the package";
    }
}

module.exports = Package;