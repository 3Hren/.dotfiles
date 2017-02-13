#!/usr/bin/env python

import sys
import msgpack
import json

if __name__ == '__main__':
    print(json.dumps(msgpack.loads(sys.stdin.read()), indent=4))
