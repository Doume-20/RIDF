class Package {
    
    async evaluate(execution, options) {
        return true;
    }

    async execute(execution, options) {
        const engine = execution.service();
        const args = [
            options["install_uninstall"],
            options["plugins"],
            options["fake_enroll_machine"]
        ]
        const result = await engine.executeFile('Install.ps1', args , 'Setup Web Browser plugins');
        if (result.code !== 0)
            throw "Could not install the package through Powershell Script";
       
    }
}

module.exports = Package;
