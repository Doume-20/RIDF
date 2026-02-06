class Package {
    async evaluate(execution, options) {
        return true;
    }

    async execute(execution, options) {
        const engine = execution.service();
        const result = await engine.executeFile('install_ppkg.ps1', [], 'Installation compte Jeune et outils BIOS');
        if (result.code !== 0)
            throw "Erreur lors de l installation compte Jeune et outils BIOS";
    }
}

module.exports = Package;