class Package {
    async evaluate(execution, options) {
        const engine = execution.interactive(false, true);

        const result = await engine.executeFile('Evaluate.ps1', [execution.metadata.software.version], 'Verify Windows App runtime version');

        return result.code !== 0; // Whether to execute
    }

    async execute(execution, options) {
        await this.executeWithEngine("Provision", execution.service());
        await this.executeWithEngine("Register", execution.interactive(false, true));
    }

    async executeWithEngine(name, engine) {
        const result = await engine.executeFile(`Execute.${name}.ps1`, [], 'Install Windows App runtime');

        if (result.code !== 0)
            throw "Could not install the package";
    }
}

module.exports = Package;