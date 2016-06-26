import 'core-js/es6';
import 'core-js/fn/array/includes';
import 'reflect-metadata';
require('zone.js/dist/zone');

Error['stackTraceLimit'] = Infinity;
require('zone.js/dist/long-stack-trace-zone');
