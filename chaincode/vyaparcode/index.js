/*
 * SPDX-License-Identifier: Apache-2.0
 */

'use strict';

const assetContract = require('./lib/assetContract');
const vyaparContract = require('./lib/vyaparContract');
const privateAssetContract = require('./lib/privateAssetContract');

module.exports.assetContract = assetContract;
module.exports.vyaparContract = vyaparContract;
module.exports.privateAssetContract = privateAssetContract;

module.exports.contracts = [assetContract, vyaparContract, privateAssetContract];


