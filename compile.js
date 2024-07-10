import fs from 'fs-extra';
import fse from 'fs-extra';
import { globby } from 'globby';
import handlebars from 'handlebars';
import path from 'path';
import chokidar from 'chokidar';
import handlebarsInit from './node_modules/@qld-gov-au/qgds-bootstrap5/dist/assets/node/handlebars.init.min.js'

async function compileTemplates() {
    handlebarsInit.init(handlebars);
    const templates = await globby('src/templates/**/*.hbs');

    for (const templatePath of templates) {
        const templateContent = await fs.readFile(templatePath, 'utf8');
        const template = handlebars.compile(templateContent);

        const jsonPath = templatePath.replace('.hbs', '.json');
        let context = {};

        if (await fs.pathExists(jsonPath)) {
            context = await fs.readJson(jsonPath);
        }

        const result = template(context);

        const relativePath = path.relative('src/templates', templatePath);
        const outputPath = path.join('dist', relativePath.replace('.hbs', '.html'));

        await fs.ensureDir(path.dirname(outputPath));
        await fs.writeFile(outputPath, result, 'utf8');

        console.log(`Compiled ${templatePath} to ${outputPath}`);
    }
}
async function copyAssets() {
    const src = path.join('node_modules', '@qld-gov-au', 'qgds-bootstrap5', 'dist', 'assets');
    const dest = path.join( 'dist', 'assets');

    // Ensure destination directory exists
    fse.ensureDir(dest, err => {
        if (err) {
            console.error(`Error ensuring directory exists: ${err}`);
        } else {
            // Copy the directory
            fse.copy(src, dest, err => {
                if (err) {
                    console.error(`Error copying directory: ${err}`);
                } else {
                    console.log(`Copied ${src} to ${dest}`);
                }
            });
        }
    });


}

async function cleanBuildFolder() {
    await fs.remove('dist');
    console.log('Dist folder cleaned');
}

async function build(options) {
    if (options.clean) {
        await cleanBuildFolder();
    }
    await compileTemplates();
    await copyAssets();
}

function watchFiles() {
    const watcher = chokidar.watch('src/templates/**/*.{hbs,json}', {
        ignored: /(^|[\/\\])\../, // ignore dotfiles
        persistent: true
    });

    watcher.on('change', async (filePath) => {
        console.log(`File ${filePath} has been changed`);
        await compileTemplates();
    });

    console.log('Watching for changes...');
}

function parseArguments() {
    const args = process.argv.slice(2);
    const options = {
        watch: false,
        clean: false
    };

    if (args) {
        for (const arg of args) {
            if (arg === '--watch') {
                options.watch = true;
            } else if (arg === '--clean') {
                options.clean = true;
            }
        }
    }

    return options;
}

(async () => {
    const options = parseArguments();
    await build(options);

    if (options.watch) {
        watchFiles();
    }
})().catch(err => {
    console.error(err);
    process.exit(1);
});
