#! /usr/bin/env node

const fs = require('fs/promises');
const path = require('path');
const { promisify } = require('util');
const { Command } = require('commander');
const { glob: globCb } = require('glob');
const deepMerge = require('deepmerge');

const program = new Command();

process.env.JEST_WORKER_ID = 1; // setting this to bypass the auto run from upstream

const { convertPoToJed, convertPoFileForLocale } = require('../../../scripts/frontend/po_to_json');

const glob = promisify(globCb);
const jhLangs = ['en', 'zh_CN', 'zh_TW'];

function getLocales(root, ignore = []) {
  return glob('*/*.po', { cwd: root, ignore });
}

async function generateJihuLocales(localeRoot, outputDir) {
  const jhLocaleRoot = path.resolve(__dirname, '../../locale');
  const jhLocales = await getLocales(jhLocaleRoot);

  return Promise.all(
    jhLocales.map(async (localeFile) => {
      const locale = path.dirname(localeFile);
      const outDir = path.join(outputDir, locale);

      let upstreamContent;
      try {
        upstreamContent = await fs.readFile(path.join(localeRoot, localeFile), 'utf-8');
      } catch (e) {
        upstreamContent = '';
      }
      const jhContent = await fs.readFile(path.join(jhLocaleRoot, localeFile), 'utf-8');

      const { jed: upstreamJed } = convertPoToJed(upstreamContent);
      const { jed: jhJed } = convertPoToJed(jhContent);
      const combinedJed = deepMerge(upstreamJed, jhJed, {
        arrayMerge: (_, sourceArray) => sourceArray,
      });

      await fs.mkdir(outDir, { recursive: true });
      await fs.writeFile(
        path.join(outputDir, locale, 'app.js'),
        `window.translations = ${JSON.stringify(combinedJed)}`,
        'utf-8',
      );

      console.log(`Generated ${locale}/app.js in ${outDir}`);
    }),
  );
}

async function main({ localeRoot, outputDir } = {}) {
  const jhLangsPattern = jhLangs.map((lang) => `${lang}/*.po`);
  const upstreamLocales = await getLocales(localeRoot, jhLangsPattern);
  console.log('Starting to generate shared locales');
  await Promise.all(
    upstreamLocales.map((localeFile) => {
      const locale = path.dirname(localeFile);
      return convertPoFileForLocale({
        locale,
        localeFile: path.join(localeRoot, localeFile),
        resultDir: path.join(outputDir, locale),
      });
    }),
  );

  console.log('Starting to generate Jihu locales');
  await generateJihuLocales(localeRoot, outputDir);
  console.log('Jihu locales generated');
}

program
  .option('-l, --locale-root <locale_root>', 'Extract messages from subfolders in this directory')
  .option('-o, --output-dir <output_dir>', 'Write app.js files into subfolders in this directory');
program.parse(process.argv);
const args = program.opts();

main(args).catch((e) => {
  console.log(e);
  console.warn(`Something went wrong: ${e.message}`);
  console.warn(program.outputHelp());
  process.exitCode = 1;
});
