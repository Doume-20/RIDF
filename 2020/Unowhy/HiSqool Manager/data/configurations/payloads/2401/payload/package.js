class Package {
    async evaluate(execution, options) {
        return true;
    }

    async execute(execution, options) {;
        const engine = execution.service();

        await engine.executeFile('Execute.ps1', [], 'Apply policy');
    }
}

module.exports = Package;