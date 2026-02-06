class Package {
    async evaluate(execution, options) {
        const engine = execution.service();

        const result = await engine.executeFile('Evaluate.ps1', [], 'Verify Sqool Tools (Rust) version');

        return result.code !== 0; // Whether to execute
    }

    async execute(execution, options) {
        const engine = execution.service();

        const result = await engine.executeFile('Execute.ps1', [], 'Install Sqool Tools (Rust) binaries');

        if (result.code !== 0)
            throw "Could not install the package";
    }
}

module.exports = Package;