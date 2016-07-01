var webpackMerge = require('webpack-merge');
var commonConfig = require('./webpack.common.js');

const ENV = process.env.NODE_ENV = process.env.ENV = 'test';

module.exports = webpackMerge(commonConfig, {
  devtool: 'inline-source-map',

  plugins: []
});
