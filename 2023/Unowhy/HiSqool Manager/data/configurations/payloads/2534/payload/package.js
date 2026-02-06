class Package {
    async evaluate(execution, options) {
        const trigger = execution.trigger;
        const script = execution.name;

        if (trigger === 'schedule' || trigger === script) {
            return true;
        }

        // Register the schedule
        const service = execution.application.get('SchedulerService');
        
        service.addSchedule('facts', {
            interval: (options?.period ?? 30) * 60 * 1000,
            unitName: script,
            immediate: true
        });

        return false;
    }

    async execute(execution, options) {
        const facts = execution.application.get('DeviceFactsService');
        const information = execution.application.get('DeviceInformationService');

        const version = execution.version || 0;
        const battery = await information.getBattryInformation();

        // Must use a single editor (or commit for each editor)
        const editor = facts.editor;

        try {
            const engine = execution.service();

            const script = `& '${process.env.ProgramFiles}\\Unowhy\\HiSqool Manager\\sqoolctl\\sqoolfct.exe' 'evaluate'`;
            const result = await engine.executeScript(script, [], 'Evaluate facts');

            for (const [name, value] of Object.entries(JSON.parse(result.output))) {
                editor.put(`System\\Platform\\${name}`, value);
            }
        } catch (error) {
            execution.logger.error(error);
        }

        editor.put('manager_version', version)
              .put('battery_level', battery.percent)
              .put('battery_charging', battery.isCharging || false)

        await editor.commit();

        await facts.uploadFacts();
    }
}

module.exports = Package;