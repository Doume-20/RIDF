class Package {
    async evaluate(execution, options) {
        return true;
    }

    async execute(execution, options) {
        const engine = execution.service();

        const result = await engine.executeFile('Execute.ps1', [options], 'Apply Wi-Fi settings');

        if (result.code !== 0)
            throw "Could not apply Wi-Fi settings";
    }
}

module.exports = Package;