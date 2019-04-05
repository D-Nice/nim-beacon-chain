# Copyright (c) 2018 Status Research & Development GmbH
# Licensed and distributed under either of
#   * MIT license (license terms in the root directory or at http://opensource.org/licenses/MIT).
#   * Apache v2 license (license terms in the root directory or at http://www.apache.org/licenses/LICENSE-2.0).
# at your option. This file may not be copied, modified, or distributed except according to those terms.

import
  math,unittest, sequtils,
  ../beacon_chain/spec/[helpers, datatypes, digest, validator]

func sumCommittees(v: openArray[seq[ValidatorIndex]], reqCommitteeLen: int): int =
  for x in v:
    ## This only holds when num_validators is divisible by
    ## SLOTS_PER_EPOCH * get_committee_count_per_slot(len(validators))
    ## as, in general, not all committees can be equally sized.
    doAssert x.len == reqCommitteeLen
    inc result, x.len

func checkPermutation(index: int, list_size: uint64,
                      permuted_index: int, seed: Eth2Digest): bool =
  let
    s = get_shuffled_seq(seed, list_size)
  s[index] == permuted_index.ValidatorIndex

suite "Validators":
  ## For now just test that we can compile and execute block processing with mock data.
  ## https://github.com/status-im/nim-beacon-chain/issues/1
  ## https://github.com/sigp/lighthouse/blob/ba548e49a52687a655c61b443b6835d79c6d4236/beacon_chain/validator_shuffling/src/shuffle.rs
  test "Validator shuffling":
    let
      num_validators = 32*1024
      validators = repeat(
        Validator(
          exit_epoch: FAR_FUTURE_EPOCH
        ), num_validators)
      s = get_shuffling(Eth2Digest(), validators, GENESIS_EPOCH)
      committees = get_epoch_committee_count(len(validators)).int
    check:
      # def b(s): return "Eth2Digest(data: [0x" + "'u8, 0x".join((s[i:i+2] for i in range(0, 64, 2))) + "'u8])"
      # TODO read YAML file directly from test case generator
      checkPermutation(0, 1, 0, Eth2Digest(data: [0xc0'u8, 0xc7'u8, 0xf2'u8, 0x26'u8, 0xfb'u8, 0xd5'u8, 0x74'u8, 0xa8'u8, 0xc6'u8, 0x3d'u8, 0xc2'u8, 0x68'u8, 0x64'u8, 0xc2'u8, 0x78'u8, 0x33'u8, 0xea'u8, 0x93'u8, 0x1e'u8, 0x7c'u8, 0x70'u8, 0xb3'u8, 0x44'u8, 0x09'u8, 0xba'u8, 0x76'u8, 0x5f'u8, 0x3d'u8, 0x20'u8, 0x31'u8, 0x63'u8, 0x3d'u8]))
      checkPermutation(0, 2, 0, Eth2Digest(data: [0xb2'u8, 0x04'u8, 0x20'u8, 0xb2'u8, 0xb7'u8, 0xb1'u8, 0xc6'u8, 0x46'u8, 0x00'u8, 0xcb'u8, 0xe9'u8, 0x62'u8, 0x54'u8, 0x40'u8, 0x52'u8, 0xd0'u8, 0xbb'u8, 0xe1'u8, 0x3d'u8, 0xa4'u8, 0x03'u8, 0x95'u8, 0x0d'u8, 0x19'u8, 0x8d'u8, 0x4f'u8, 0x4e'u8, 0xa2'u8, 0x87'u8, 0x62'u8, 0x95'u8, 0x3f'u8]))
      checkPermutation(1, 2, 0, Eth2Digest(data: [0x11'u8, 0xf1'u8, 0x32'u8, 0x2c'u8, 0x3a'u8, 0x4c'u8, 0xfc'u8, 0xe2'u8, 0x0e'u8, 0xfb'u8, 0x7d'u8, 0x7e'u8, 0xca'u8, 0x50'u8, 0x29'u8, 0x14'u8, 0x70'u8, 0x04'u8, 0x3d'u8, 0x6e'u8, 0x8a'u8, 0x2c'u8, 0x62'u8, 0x95'u8, 0x6e'u8, 0x68'u8, 0x75'u8, 0x71'u8, 0x60'u8, 0x7d'u8, 0x3f'u8, 0x0e'u8]))
      checkPermutation(0, 3, 2, Eth2Digest(data: [0x5b'u8, 0xd0'u8, 0xaf'u8, 0x3f'u8, 0x74'u8, 0xfe'u8, 0x69'u8, 0x86'u8, 0xbb'u8, 0x99'u8, 0xb3'u8, 0xec'u8, 0xc0'u8, 0xea'u8, 0x15'u8, 0xa4'u8, 0x03'u8, 0x45'u8, 0x6c'u8, 0xe7'u8, 0x08'u8, 0xc0'u8, 0x5c'u8, 0xee'u8, 0xed'u8, 0xdc'u8, 0x0a'u8, 0x42'u8, 0x05'u8, 0xca'u8, 0xf0'u8, 0x72'u8]))
      checkPermutation(1, 3, 1, Eth2Digest(data: [0xba'u8, 0x06'u8, 0xff'u8, 0x9b'u8, 0xde'u8, 0x03'u8, 0xf3'u8, 0x7e'u8, 0xdd'u8, 0xea'u8, 0xcb'u8, 0x26'u8, 0x1a'u8, 0x51'u8, 0x10'u8, 0x96'u8, 0x76'u8, 0xd5'u8, 0x49'u8, 0xc1'u8, 0xbe'u8, 0xa3'u8, 0xb8'u8, 0x1e'u8, 0xdd'u8, 0x82'u8, 0xdf'u8, 0x68'u8, 0xcc'u8, 0x03'u8, 0xa9'u8, 0x7f'u8]))
      checkPermutation(2, 3, 2, Eth2Digest(data: [0xf5'u8, 0x8a'u8, 0x89'u8, 0x70'u8, 0xc6'u8, 0x3c'u8, 0xa8'u8, 0x6d'u8, 0xd3'u8, 0xb8'u8, 0xb8'u8, 0xa6'u8, 0x15'u8, 0x30'u8, 0x2e'u8, 0xc0'u8, 0x6c'u8, 0xdd'u8, 0xea'u8, 0x12'u8, 0x79'u8, 0xbf'u8, 0x4a'u8, 0x27'u8, 0x25'u8, 0xc7'u8, 0x81'u8, 0xce'u8, 0x6a'u8, 0xba'u8, 0x34'u8, 0x8d'u8]))
      checkPermutation(0, 1024, 1005, Eth2Digest(data: [0x38'u8, 0x35'u8, 0x56'u8, 0xe2'u8, 0x3f'u8, 0xcb'u8, 0x9e'u8, 0x73'u8, 0xc2'u8, 0x3a'u8, 0xd3'u8, 0x3c'u8, 0xfb'u8, 0x50'u8, 0xf4'u8, 0xc0'u8, 0x98'u8, 0xf4'u8, 0x96'u8, 0x88'u8, 0xa8'u8, 0x4b'u8, 0x12'u8, 0x8c'u8, 0x28'u8, 0x85'u8, 0x96'u8, 0x0e'u8, 0x5f'u8, 0x1b'u8, 0x39'u8, 0x82'u8]))
      checkPermutation(1023, 1024, 934, Eth2Digest(data: [0x2e'u8, 0xe5'u8, 0xda'u8, 0xb3'u8, 0x0a'u8, 0xd1'u8, 0x58'u8, 0x0c'u8, 0xda'u8, 0xbb'u8, 0x17'u8, 0x5a'u8, 0x4b'u8, 0x15'u8, 0x12'u8, 0xca'u8, 0xc5'u8, 0x56'u8, 0x68'u8, 0x66'u8, 0xd6'u8, 0x5a'u8, 0x15'u8, 0xe9'u8, 0xe2'u8, 0x2c'u8, 0x84'u8, 0x44'u8, 0xf4'u8, 0x60'u8, 0xc9'u8, 0xdc'u8]))
      checkPermutation(3925, 4040, 32, Eth2Digest(data: [0x34'u8, 0xa3'u8, 0xc1'u8, 0x3f'u8, 0x21'u8, 0x1e'u8, 0x63'u8, 0xc5'u8, 0x6e'u8, 0x9e'u8, 0x11'u8, 0x87'u8, 0xf3'u8, 0x1a'u8, 0x56'u8, 0xa4'u8, 0x23'u8, 0x0d'u8, 0x8d'u8, 0x5b'u8, 0xf5'u8, 0xe5'u8, 0x84'u8, 0xf0'u8, 0xe4'u8, 0xfe'u8, 0x93'u8, 0x94'u8, 0x6a'u8, 0xf9'u8, 0x1c'u8, 0xce'u8]))
      checkPermutation(885, 2417, 1822, Eth2Digest(data: [0x13'u8, 0x46'u8, 0xe3'u8, 0x97'u8, 0x08'u8, 0x15'u8, 0x10'u8, 0x71'u8, 0x54'u8, 0xb5'u8, 0x8b'u8, 0x1e'u8, 0xff'u8, 0x41'u8, 0x1b'u8, 0xfc'u8, 0xa3'u8, 0x34'u8, 0x2e'u8, 0xa0'u8, 0xd8'u8, 0x28'u8, 0x2a'u8, 0x86'u8, 0x30'u8, 0x4d'u8, 0x79'u8, 0xd6'u8, 0x2d'u8, 0x5f'u8, 0x3c'u8, 0x52'u8]))
      checkPermutation(840, 1805, 808, Eth2Digest(data: [0x08'u8, 0x10'u8, 0xc1'u8, 0x04'u8, 0xb7'u8, 0x5e'u8, 0x25'u8, 0xbf'u8, 0x89'u8, 0xc0'u8, 0x06'u8, 0x6d'u8, 0xee'u8, 0xbc'u8, 0x34'u8, 0x61'u8, 0x93'u8, 0x7f'u8, 0xc0'u8, 0xe7'u8, 0x2a'u8, 0xe0'u8, 0x4e'u8, 0xe7'u8, 0x4f'u8, 0x24'u8, 0x56'u8, 0x16'u8, 0xc1'u8, 0x57'u8, 0x18'u8, 0xdf'u8]))
      checkPermutation(881, 1788, 582, Eth2Digest(data: [0x34'u8, 0xad'u8, 0xb3'u8, 0x5f'u8, 0x3f'u8, 0xc2'u8, 0x88'u8, 0x0d'u8, 0x22'u8, 0x0e'u8, 0x52'u8, 0x01'u8, 0x20'u8, 0xa0'u8, 0x32'u8, 0xbb'u8, 0xaa'u8, 0x0f'u8, 0x4b'u8, 0xd7'u8, 0xa5'u8, 0xfc'u8, 0xf1'u8, 0xc2'u8, 0x26'u8, 0x9d'u8, 0xe2'u8, 0x10'u8, 0x75'u8, 0xe7'u8, 0xa4'u8, 0x64'u8]))
      checkPermutation(1362, 1817, 1018, Eth2Digest(data: [0xc9'u8, 0xb0'u8, 0xc7'u8, 0x6e'u8, 0x11'u8, 0xf4'u8, 0xc3'u8, 0xc3'u8, 0xc3'u8, 0x8b'u8, 0x44'u8, 0x7a'u8, 0xca'u8, 0x53'u8, 0x52'u8, 0xd9'u8, 0x31'u8, 0x32'u8, 0xad'u8, 0x56'u8, 0x78'u8, 0xda'u8, 0x42'u8, 0x0c'u8, 0xa2'u8, 0xe6'u8, 0x9d'u8, 0x92'u8, 0x58'u8, 0x8e'u8, 0x0f'u8, 0xba'u8]))
      checkPermutation(28, 111, 0, Eth2Digest(data: [0x29'u8, 0x31'u8, 0x45'u8, 0xc3'u8, 0x1a'u8, 0xeb'u8, 0x3e'u8, 0xb2'u8, 0x9c'u8, 0xcd'u8, 0xf3'u8, 0x32'u8, 0x7d'u8, 0x0f'u8, 0x3d'u8, 0xd4'u8, 0x59'u8, 0x2c'u8, 0xdf'u8, 0xb2'u8, 0xfa'u8, 0xd3'u8, 0x70'u8, 0x32'u8, 0x29'u8, 0xc6'u8, 0xc2'u8, 0xe7'u8, 0x20'u8, 0xdc'u8, 0x79'u8, 0x2f'u8]))
      checkPermutation(959, 2558, 2094, Eth2Digest(data: [0xc9'u8, 0xf4'u8, 0xc5'u8, 0xfb'u8, 0xb2'u8, 0xa3'u8, 0x97'u8, 0xfd'u8, 0x8e'u8, 0xa3'u8, 0x6d'u8, 0xbf'u8, 0xce'u8, 0xc0'u8, 0xd7'u8, 0x33'u8, 0xd0'u8, 0xaf'u8, 0x7e'u8, 0xc3'u8, 0xa0'u8, 0x3d'u8, 0x78'u8, 0x9a'u8, 0x66'u8, 0x23'u8, 0x1f'u8, 0x3b'u8, 0xc7'u8, 0xca'u8, 0xfa'u8, 0x5e'u8]))
      checkPermutation(887, 2406, 831, Eth2Digest(data: [0x56'u8, 0x57'u8, 0x29'u8, 0xe0'u8, 0xd5'u8, 0xde'u8, 0x52'u8, 0x4e'u8, 0x6d'u8, 0xee'u8, 0x54'u8, 0xd1'u8, 0xb8'u8, 0xb5'u8, 0x88'u8, 0x2a'u8, 0xd8'u8, 0xe5'u8, 0x5c'u8, 0x18'u8, 0xa3'u8, 0x04'u8, 0x62'u8, 0xac'u8, 0x02'u8, 0xc4'u8, 0xbb'u8, 0x86'u8, 0xc2'u8, 0x7d'u8, 0x26'u8, 0xcb'u8]))
      checkPermutation(3526, 3674, 3531, Eth2Digest(data: [0x29'u8, 0x51'u8, 0x39'u8, 0x5b'u8, 0x1a'u8, 0x1b'u8, 0xbd'u8, 0xa8'u8, 0xd5'u8, 0x3b'u8, 0x77'u8, 0x6c'u8, 0x7f'u8, 0xc8'u8, 0xbd'u8, 0xad'u8, 0x60'u8, 0x30'u8, 0xde'u8, 0x94'u8, 0x3c'u8, 0x4e'u8, 0x3f'u8, 0x93'u8, 0x82'u8, 0x02'u8, 0xac'u8, 0x55'u8, 0x3f'u8, 0x44'u8, 0x38'u8, 0x1d'u8]))
      checkPermutation(978, 3175, 2257, Eth2Digest(data: [0x74'u8, 0xaa'u8, 0xc2'u8, 0x35'u8, 0x23'u8, 0xcb'u8, 0x45'u8, 0xb7'u8, 0xee'u8, 0x52'u8, 0xd5'u8, 0xd2'u8, 0xf7'u8, 0xb2'u8, 0xd2'u8, 0x4e'u8, 0xbc'u8, 0x6b'u8, 0xf2'u8, 0xd6'u8, 0x3e'u8, 0xf1'u8, 0x89'u8, 0xef'u8, 0xcc'u8, 0xab'u8, 0xc4'u8, 0xa1'u8, 0x6b'u8, 0xb1'u8, 0x7c'u8, 0xd8'u8]))
      checkPermutation(37, 231, 48, Eth2Digest(data: [0xe4'u8, 0x08'u8, 0x3e'u8, 0x61'u8, 0xb3'u8, 0x19'u8, 0x31'u8, 0xba'u8, 0xd6'u8, 0x62'u8, 0x39'u8, 0x27'u8, 0x58'u8, 0xe8'u8, 0xbc'u8, 0x30'u8, 0xa4'u8, 0xce'u8, 0x7b'u8, 0x26'u8, 0xb6'u8, 0x89'u8, 0x7c'u8, 0x22'u8, 0x21'u8, 0xa3'u8, 0x35'u8, 0x8f'u8, 0x25'u8, 0xfd'u8, 0xc1'u8, 0xd8'u8]))
      checkPermutation(340, 693, 234, Eth2Digest(data: [0x80'u8, 0x89'u8, 0xc1'u8, 0xf2'u8, 0x42'u8, 0xaa'u8, 0x48'u8, 0xc6'u8, 0x61'u8, 0x11'u8, 0x80'u8, 0xf2'u8, 0x21'u8, 0xc1'u8, 0x20'u8, 0xe9'u8, 0x30'u8, 0xad'u8, 0xee'u8, 0xca'u8, 0xf3'u8, 0x08'u8, 0x4b'u8, 0x2b'u8, 0x85'u8, 0xf9'u8, 0xb1'u8, 0xdf'u8, 0xeb'u8, 0xe3'u8, 0x4f'u8, 0x63'u8]))
      checkPermutation(0, 9, 1, Eth2Digest(data: [0x7f'u8, 0xda'u8, 0x0a'u8, 0xb6'u8, 0xa7'u8, 0x46'u8, 0xb6'u8, 0xb0'u8, 0x20'u8, 0x6f'u8, 0xeb'u8, 0xb8'u8, 0x25'u8, 0x98'u8, 0x91'u8, 0xe0'u8, 0xe6'u8, 0xf8'u8, 0x8b'u8, 0xf5'u8, 0x21'u8, 0x43'u8, 0xb2'u8, 0x0d'u8, 0x6c'u8, 0x78'u8, 0xca'u8, 0xf7'u8, 0xca'u8, 0xf8'u8, 0xe7'u8, 0xb3'u8]))
      checkPermutation(200, 1108, 952, Eth2Digest(data: [0x87'u8, 0xb2'u8, 0x10'u8, 0xd0'u8, 0x00'u8, 0xb5'u8, 0xf5'u8, 0x7e'u8, 0x98'u8, 0x34'u8, 0x38'u8, 0x8d'u8, 0x4b'u8, 0xc2'u8, 0xb8'u8, 0x6a'u8, 0xe8'u8, 0xb3'u8, 0x13'u8, 0x83'u8, 0xfa'u8, 0x10'u8, 0xa3'u8, 0x4b'u8, 0x02'u8, 0x95'u8, 0x46'u8, 0xc2'u8, 0xeb'u8, 0xab'u8, 0xb8'u8, 0x07'u8]))
      checkPermutation(1408, 1531, 584, Eth2Digest(data: [0x06'u8, 0x70'u8, 0xa7'u8, 0x8b'u8, 0x38'u8, 0xe0'u8, 0x41'u8, 0x9a'u8, 0xae'u8, 0xad'u8, 0x5d'u8, 0x1c'u8, 0xc8'u8, 0xf4'u8, 0x0f'u8, 0x58'u8, 0x04'u8, 0x4b'u8, 0x70'u8, 0x76'u8, 0xce'u8, 0xd8'u8, 0x19'u8, 0x3c'u8, 0x08'u8, 0xb5'u8, 0x80'u8, 0xdd'u8, 0x95'u8, 0xa1'u8, 0x35'u8, 0x55'u8]))
      checkPermutation(1704, 1863, 1022, Eth2Digest(data: [0xdb'u8, 0xf7'u8, 0x86'u8, 0x65'u8, 0x19'u8, 0x0a'u8, 0x61'u8, 0x33'u8, 0x19'u8, 0x1e'u8, 0x91'u8, 0xab'u8, 0x35'u8, 0xb1'u8, 0x10'u8, 0x6e'u8, 0x89'u8, 0x84'u8, 0xdf'u8, 0xc0'u8, 0xdf'u8, 0xa3'u8, 0x60'u8, 0x18'u8, 0x00'u8, 0x4f'u8, 0x88'u8, 0x0b'u8, 0x43'u8, 0x1c'u8, 0x2a'u8, 0x14'u8]))
      checkPermutation(793, 3938, 2607, Eth2Digest(data: [0x54'u8, 0xbf'u8, 0x01'u8, 0x92'u8, 0x29'u8, 0x2f'u8, 0xfa'u8, 0xe0'u8, 0xbf'u8, 0x39'u8, 0xb3'u8, 0x9f'u8, 0x12'u8, 0xe0'u8, 0x54'u8, 0x0b'u8, 0x97'u8, 0x59'u8, 0x1a'u8, 0xf0'u8, 0xa2'u8, 0x98'u8, 0x0d'u8, 0x32'u8, 0xf2'u8, 0x77'u8, 0xbd'u8, 0x33'u8, 0x20'u8, 0x13'u8, 0x95'u8, 0xd3'u8]))
      checkPermutation(14, 28, 10, Eth2Digest(data: [0x43'u8, 0x05'u8, 0x44'u8, 0x17'u8, 0xc6'u8, 0x05'u8, 0x64'u8, 0x04'u8, 0xc5'u8, 0x86'u8, 0xc9'u8, 0x07'u8, 0xdf'u8, 0xc5'u8, 0xfc'u8, 0xeb'u8, 0x66'u8, 0xeb'u8, 0xef'u8, 0x54'u8, 0x1d'u8, 0x14'u8, 0x3b'u8, 0x00'u8, 0xa3'u8, 0xb6'u8, 0x76'u8, 0xf3'u8, 0xc0'u8, 0xfb'u8, 0xf4'u8, 0xc5'u8]))
      checkPermutation(2909, 3920, 726, Eth2Digest(data: [0x5e'u8, 0xab'u8, 0xf2'u8, 0x89'u8, 0xfd'u8, 0xcf'u8, 0xe0'u8, 0xa3'u8, 0xab'u8, 0xa3'u8, 0x3a'u8, 0x18'u8, 0x5f'u8, 0xb1'u8, 0xa4'u8, 0xae'u8, 0x2f'u8, 0x2b'u8, 0x6f'u8, 0x78'u8, 0xda'u8, 0xf6'u8, 0x1f'u8, 0x5d'u8, 0x35'u8, 0x69'u8, 0x71'u8, 0xe0'u8, 0xcb'u8, 0x27'u8, 0x02'u8, 0x07'u8]))
      checkPermutation(1943, 1959, 1292, Eth2Digest(data: [0xca'u8, 0x86'u8, 0x32'u8, 0x2d'u8, 0xb5'u8, 0x69'u8, 0x27'u8, 0xd7'u8, 0x27'u8, 0x10'u8, 0x1e'u8, 0x31'u8, 0xc9'u8, 0x3f'u8, 0x61'u8, 0x6f'u8, 0x74'u8, 0x63'u8, 0x17'u8, 0xd2'u8, 0x9a'u8, 0xa1'u8, 0x0d'u8, 0x88'u8, 0xf3'u8, 0x71'u8, 0x59'u8, 0x29'u8, 0x63'u8, 0xde'u8, 0x92'u8, 0xaa'u8]))
      checkPermutation(1647, 2094, 1805, Eth2Digest(data: [0x3c'u8, 0xfe'u8, 0x27'u8, 0x42'u8, 0x30'u8, 0xa1'u8, 0x12'u8, 0xbc'u8, 0x68'u8, 0x61'u8, 0x48'u8, 0x82'u8, 0x64'u8, 0x53'u8, 0x39'u8, 0xfd'u8, 0xa2'u8, 0xf1'u8, 0x34'u8, 0x50'u8, 0x1a'u8, 0x04'u8, 0x20'u8, 0x79'u8, 0xd6'u8, 0x20'u8, 0xec'u8, 0x65'u8, 0xcf'u8, 0x8d'u8, 0x3f'u8, 0xa6'u8]))
      checkPermutation(1012, 1877, 216, Eth2Digest(data: [0x7b'u8, 0x5f'u8, 0xf8'u8, 0xa8'u8, 0x48'u8, 0xaf'u8, 0x32'u8, 0xd8'u8, 0x5c'u8, 0x6d'u8, 0x37'u8, 0xc2'u8, 0x6e'u8, 0x61'u8, 0xa5'u8, 0x7e'u8, 0x96'u8, 0x78'u8, 0x0f'u8, 0xce'u8, 0xbc'u8, 0x35'u8, 0x0a'u8, 0xd1'u8, 0x84'u8, 0x5e'u8, 0x83'u8, 0xfe'u8, 0x5e'u8, 0x46'u8, 0x79'u8, 0xac'u8]))
      checkPermutation(35, 2081, 1458, Eth2Digest(data: [0x40'u8, 0x69'u8, 0x1a'u8, 0xa3'u8, 0x1a'u8, 0x49'u8, 0xc2'u8, 0x39'u8, 0x1e'u8, 0x02'u8, 0x5e'u8, 0xc2'u8, 0x72'u8, 0xc8'u8, 0x12'u8, 0x51'u8, 0x0c'u8, 0xb0'u8, 0x7c'u8, 0x05'u8, 0x5f'u8, 0x62'u8, 0x01'u8, 0xe8'u8, 0x44'u8, 0x79'u8, 0x49'u8, 0x93'u8, 0x26'u8, 0x33'u8, 0x06'u8, 0x28'u8]))
      checkPermutation(1136, 2189, 1579, Eth2Digest(data: [0x31'u8, 0xa0'u8, 0xde'u8, 0xb2'u8, 0xc8'u8, 0xc5'u8, 0xf8'u8, 0x09'u8, 0xf4'u8, 0x13'u8, 0xb7'u8, 0xa3'u8, 0x6e'u8, 0xc6'u8, 0x80'u8, 0xee'u8, 0x8b'u8, 0x19'u8, 0xbb'u8, 0xb9'u8, 0xa3'u8, 0x9c'u8, 0x4e'u8, 0x20'u8, 0x73'u8, 0x26'u8, 0x15'u8, 0x58'u8, 0x64'u8, 0xbc'u8, 0x8b'u8, 0xe5'u8]))
      checkPermutation(1775, 3434, 707, Eth2Digest(data: [0x92'u8, 0xf3'u8, 0x0d'u8, 0x85'u8, 0x56'u8, 0x38'u8, 0x2b'u8, 0x72'u8, 0xa5'u8, 0x79'u8, 0x7d'u8, 0xb8'u8, 0x11'u8, 0x48'u8, 0x6e'u8, 0x7a'u8, 0x21'u8, 0x3e'u8, 0x01'u8, 0x45'u8, 0xd6'u8, 0xc9'u8, 0x46'u8, 0xe5'u8, 0x12'u8, 0x1a'u8, 0xa6'u8, 0xa8'u8, 0xf7'u8, 0x61'u8, 0xd1'u8, 0x64'u8]))
      checkPermutation(1109, 2010, 433, Eth2Digest(data: [0x09'u8, 0x3f'u8, 0xb9'u8, 0x76'u8, 0xf2'u8, 0x49'u8, 0x73'u8, 0x61'u8, 0x89'u8, 0x70'u8, 0x12'u8, 0xdf'u8, 0xa6'u8, 0xdc'u8, 0x01'u8, 0x90'u8, 0x09'u8, 0xed'u8, 0xa2'u8, 0xe4'u8, 0x8b'u8, 0xbe'u8, 0xb4'u8, 0xb7'u8, 0xc5'u8, 0x6d'u8, 0x4a'u8, 0xa5'u8, 0xda'u8, 0x7d'u8, 0x5f'u8, 0x87'u8]))
      checkPermutation(359, 538, 115, Eth2Digest(data: [0xa7'u8, 0x9b'u8, 0x35'u8, 0xbe'u8, 0xac'u8, 0xbe'u8, 0x48'u8, 0xc6'u8, 0x62'u8, 0xd6'u8, 0x08'u8, 0x84'u8, 0xc7'u8, 0x04'u8, 0x04'u8, 0x00'u8, 0x24'u8, 0xc5'u8, 0x5a'u8, 0xb8'u8, 0x79'u8, 0xe5'u8, 0xf6'u8, 0x15'u8, 0x21'u8, 0x01'u8, 0x3c'u8, 0x5f'u8, 0x45'u8, 0xeb'u8, 0x3b'u8, 0x70'u8]))
      checkPermutation(1259, 1473, 1351, Eth2Digest(data: [0x02'u8, 0xc5'u8, 0x3c'u8, 0x9c'u8, 0x6d'u8, 0xdf'u8, 0x25'u8, 0x97'u8, 0x16'u8, 0xff'u8, 0x02'u8, 0xe4'u8, 0x9a'u8, 0x29'u8, 0x4e'u8, 0xba'u8, 0x33'u8, 0xe4'u8, 0xad'u8, 0x25'u8, 0x5d'u8, 0x7e'u8, 0x90'u8, 0xdb'u8, 0xef'u8, 0xdb'u8, 0xc9'u8, 0x91'u8, 0xad'u8, 0xf6'u8, 0x03'u8, 0xe5'u8]))
      checkPermutation(2087, 2634, 1497, Eth2Digest(data: [0xa5'u8, 0xa4'u8, 0xc5'u8, 0x7c'u8, 0x57'u8, 0x05'u8, 0xec'u8, 0x69'u8, 0x7a'u8, 0x74'u8, 0xe6'u8, 0xc7'u8, 0x16'u8, 0x11'u8, 0x91'u8, 0xb1'u8, 0x8f'u8, 0x58'u8, 0xca'u8, 0x88'u8, 0x2a'u8, 0x0f'u8, 0xcc'u8, 0x18'u8, 0xf6'u8, 0x8d'u8, 0xc3'u8, 0xb5'u8, 0x7a'u8, 0x1a'u8, 0xa5'u8, 0xb6'u8]))
      checkPermutation(2069, 2511, 1837, Eth2Digest(data: [0xe7'u8, 0x05'u8, 0x1e'u8, 0xbc'u8, 0x07'u8, 0xf2'u8, 0xe7'u8, 0xb4'u8, 0xd4'u8, 0xb2'u8, 0x8f'u8, 0x48'u8, 0xd1'u8, 0xe4'u8, 0x2d'u8, 0x7b'u8, 0x9d'u8, 0xce'u8, 0xc3'u8, 0x1c'u8, 0x24'u8, 0x0c'u8, 0xa6'u8, 0xe1'u8, 0xa0'u8, 0xc0'u8, 0x61'u8, 0x39'u8, 0xcc'u8, 0xfc'u8, 0x4b'u8, 0x8f'u8]))
      checkPermutation(1660, 3932, 3046, Eth2Digest(data: [0x86'u8, 0x87'u8, 0xc0'u8, 0x29'u8, 0xff'u8, 0xc4'u8, 0x43'u8, 0x87'u8, 0x95'u8, 0x27'u8, 0xa6'u8, 0x4c'u8, 0x31'u8, 0xb7'u8, 0xac'u8, 0xbb'u8, 0x38'u8, 0xab'u8, 0x6e'u8, 0x34'u8, 0x37'u8, 0x79'u8, 0xd0'u8, 0xb2'u8, 0xc6'u8, 0xe2'u8, 0x50'u8, 0x04'u8, 0x6f'u8, 0xdb'u8, 0x9d'u8, 0xe8'u8]))
      checkPermutation(379, 646, 32, Eth2Digest(data: [0x17'u8, 0xe8'u8, 0x54'u8, 0xf4'u8, 0xe8'u8, 0x04'u8, 0x01'u8, 0x34'u8, 0x5e'u8, 0x13'u8, 0xf7'u8, 0x2a'u8, 0xf4'u8, 0x5b'u8, 0x22'u8, 0x1c'u8, 0x9f'u8, 0x7a'u8, 0x84'u8, 0x0f'u8, 0x6a'u8, 0x8c'u8, 0x13'u8, 0x28'u8, 0xdd'u8, 0xf9'u8, 0xc9'u8, 0xca'u8, 0x9a'u8, 0x08'u8, 0x83'u8, 0x79'u8]))
      s.len == committees
       # 32k validators: SLOTS_PER_EPOCH slots * committee_count_per_slot =
       # get_epoch_committee_count committees.
      sumCommittees(s, num_validators div committees) == validators.len() # all validators accounted for
