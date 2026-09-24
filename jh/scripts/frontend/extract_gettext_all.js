/* eslint-disable */

const argumentsParser = require('commander');

const { GettextExtractor, JsExtractors } = require('gettext-extractor');
const {
  decorateJSParserWithVueSupport,
  decorateExtractorWithHelpers,
} = require('gettext-extractor-vue');
const vue2TemplateCompiler = require('vue-template-compiler');

const extractor = decorateExtractorWithHelpers(new GettextExtractor());

function ensureSingleLine(str) {
  // This guard makes the function significantly faster
  if (str.includes('\n') || str.includes('\r')) {
    return str
      .split(/\s*[\r\n]+\s*/)
      .filter((s) => s !== '')
      .join(' ');
  }
  return str;
}

extractor.addMessageTransformFunction(ensureSingleLine);

const jsParser = extractor.createJsParser([
  // Place all the possible expressions to extract here:
  JsExtractors.callExpression('__', {
    arguments: {
      text: 0,
    },
  }),
  JsExtractors.callExpression('n__', {
    arguments: {
      text: 0,
      textPlural: 1,
    },
  }),
  JsExtractors.callExpression('s__', {
    arguments: {
      text: 0,
    },
  }),
]);

const vueParser = decorateJSParserWithVueSupport(jsParser, {
  vue2TemplateCompiler,
});

function printJson() {
  const messages = extractor.getMessages().reduce((acc, message) => {
    let { text } = message;
    if (message.textPlural) {
      text += `\u0000${message.textPlural}`;
    }

    message.references.forEach((reference) => {
      const filename = reference.replace(/:\d+$/, '');

      if (!Array.isArray(acc[filename])) {
        acc[filename] = [];
      }

      acc[filename].push([text, reference]);
    });

    return acc;
  }, {});

  console.log(JSON.stringify(messages));
}

async function main() {
  return vueParser
    .parseFilesGlob('jh/app/assets/javascripts/**/*.{js,vue}')
    .then(() => printJson());

  throw new Error('ERROR: Please use the script correctly:');
}

main().catch((error) => {
  console.warn(error.message);
  process.exit(1);
});
