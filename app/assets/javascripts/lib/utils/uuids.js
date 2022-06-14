/**
 * @module uuids
 */

/**
 * A string or number representing a start state for a random generator
 * @typedef {(Number|String)} Seed
 */
/**
 * A UUIDv4 string in the format <code>Hex{8}-Hex{4}-4Hex{3}-[89ab]Hex{3}-Hex{12}</code>
 * @typedef {String} UUIDv4
 */

import { MersenneTwister } from 'fast-mersenne-twister';
import { isString } from 'lodash';
import stringHash from 'string-hash';
import { v4 } from 'uuid';

const getRandomUUIDFunction = () => window.crypto.randomUUID.bind(window.crypto);

function arrayOf(length) {
  return {
    using(uuidGenerator) {
      return Array(length).fill(0).map(uuidGenerator);
    },
  };
}

function getSeed(seeds) {
  return seeds.reduce((seedling, seed, i) => {
    let thisSeed = 0;

    if (Number.isInteger(seed)) {
      thisSeed = seed;
    } else if (isString(seed)) {
      thisSeed = stringHash(seed);
    }

    return seedling + (seeds.length - i) * thisSeed;
  }, 0);
}

function getPseudoRandomNumberGenerator(...seeds) {
  let seedNumber;

  if (seeds.length) {
    seedNumber = getSeed(seeds);
  } else {
    throw new Error(
      'Seeding the random number generator requires initial seed values' /* eslint-disable-line @gitlab/require-i18n-strings */,
    );
  }

  return new MersenneTwister(seedNumber);
}

function randomValuesForUuid(prng) {
  const randomValues = [];

  for (let i = 0; i <= 3; i += 1) {
    const buffer = new ArrayBuffer(4);
    const view = new DataView(buffer);

    view.setUint32(0, prng.randomNumber());

    randomValues.push(view.getUint8(0), view.getUint8(1), view.getUint8(2), view.getUint8(3));
  }

  return randomValues;
}

/**
 * Get an array of UUIDv4s
 * @param {Object} [options={}]
 * @param {Seed[]} [options.seeds=[]] - A list of mixed strings or numbers to seed the UUIDv4 generator
 * @param {Number} [options.count=1] - A total number of UUIDv4s to generate
 * @returns {UUIDv4[]} An array of UUIDv4s
 */
export function uuids({ seeds = [], count = 1 } = {}) {
  const versionFour = {
    random: () => arrayOf(count).using(getRandomUUIDFunction()),
    seeded: ({ seeds: seedValues }) => {
      const rng = getPseudoRandomNumberGenerator(...seedValues);

      return arrayOf(count).using(() => v4({ random: randomValuesForUuid(rng) }));
    },
  };
  const type = seeds.length ? 'seeded' : 'random';

  return versionFour[type]({ seeds });
}
