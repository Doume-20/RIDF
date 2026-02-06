const fs = require('fs');
const crypto = require('crypto');

const OPENSSL_PREFIX = 'Salted__';
const MESSAGE_START = 16;

class Package {
    async evaluate(execution, options) {
        const engine = execution.service();

        const result = await engine.executeFile('Evaluate.ps1', [execution.version, execution.metadata.software.version], 'Verify Device Manager version');

        if (result.code !== 0)
            return true; // Whether to execute

        if (this.mergeConfiguration(options)) {
            process.exit(0);
        }

        return false; 
    }

    async execute(execution, options) {
        const service = execution.application.get('ConfigurationService');
        const configuration = service.configuration ?? service.config;

        this.ensureConfiguration(configuration, true, false);

        this.mergeConfiguration(options)

        const engine = execution.service();

        const result = await engine.executeFile('Execute.ps1', [], 'Install Device Manager binaries');

        if (result.code !== 0)
            throw "Could not install the package";

        process.exit(0);
    }

    ensureConfiguration(actual, cypherPassword = true, cypherApiKey = false) {
        const path = `${process.env.ProgramFiles}\\Unowhy\\HiSqool Manager\\configuration.json`;

        if (fs.existsSync(path))
            return;

        const configuration = JSON.parse(JSON.stringify(actual));

        // Cypher
        for (const property in configuration.services) {
            const service = configuration.services[property];
            if (service.password && cypherPassword) {
                service.password = this.cypher(service.password, '336c91a314e275e330f61ce713e99dc50ccf51ad');
            }
            if (service.api_key && cypherApiKey) {
                service.api_key = this.cypher(service.api_key, '336c91a314e275e330f61ce713e99dc50ccf51ad');
            }
        }

        // Save
        fs.writeFileSync(path, JSON.stringify(configuration, null, 2), { encoding: 'utf-8' });
    }

    mergeConfiguration(options) {
        if (!options)
            return false; // Unchanged

        const path = `${process.env.ProgramFiles}\\Unowhy\\HiSqool Manager\\configuration.json`;

        // Load
        const actual = JSON.parse(fs.readFileSync(path, { encoding: 'utf-8' }));

        // Merge
        const merged = this.merge(actual, options);

        // Compare
        if (JSON.stringify(actual) === JSON.stringify(merged))
            return false; // Unchanged

        // Save
        fs.writeFileSync(path, JSON.stringify(merged, null, 2), { encoding: 'utf-8' });

        return true; // Changed
    }

    md5(data) {
        const hash = crypto.createHash('md5');
        hash.update(data);
        return hash.digest();
    }

    getSecretAndIv(password, salt) {
        const hash1 = this.md5(Buffer.concat([password, salt]));
        const hash2 = this.md5(Buffer.concat([hash1, password, salt]));
        const hash3 = this.md5(Buffer.concat([hash2, password, salt]));

        // then concatenate them and split _that_ to key and IV
        const total = Buffer.concat([hash1, hash2, hash3]);
        const key = total.subarray(0, 32);
        const iv = total.subarray(32, 48);

        return [key, iv];
    }

    decypher(encodedBase64Message, password) {
        const binary = Buffer.from(encodedBase64Message, 'base64');

        // Keep this for assertions
        // eslint-disable-next-line unused-imports/no-unused-vars-ts
        const prefix = binary.subarray(0, OPENSSL_PREFIX.length);
        const salt = binary.subarray(OPENSSL_PREFIX.length, MESSAGE_START);
        const message = binary.subarray(MESSAGE_START);

        const [key, iv] = this.getSecretAndIv(Buffer.from(password), salt);
        const decypherer = crypto.createDecipheriv('aes-256-cbc', key, iv);
        const part = decypherer.update(message);
        return Buffer.concat([part, decypherer.final()]).toString('utf8');
    }

    cypher(originalMessage, password) {
        const prefix = Buffer.from(OPENSSL_PREFIX, 'utf-8');
        const salt = Buffer.alloc(MESSAGE_START - OPENSSL_PREFIX.length, crypto.randomUUID());
        const message = Buffer.from(originalMessage, 'utf8');

        const [key, iv] = this.getSecretAndIv(Buffer.from(password), salt);
        const cypherer = crypto.createCipheriv('aes-256-cbc', key, iv);
        var part = cypherer.update(message);

        const binary = Buffer.concat([prefix, salt, part, cypherer.final()]);

        return binary.toString('base64');
    }

    merge(actual, request) {
        if (typeof request === 'object' && !Array.isArray(request)) {
            const result = { ...actual };
            for (const key in request) {
                if (result[key] === undefined) {
                    if (request[key] !== null) {
                        result[key] = request[key];
                    }
                } else {
                    if (request[key] === null) {
                        delete result[key];
                    } else {
                        result[key] = this.merge(result[key], request[key]);
                    }
                }
            }
            return result;
        } else {
            return request;
        }
    }
}

module.exports = Package;