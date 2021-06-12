#!/usr/bin/env python3

import sys
import os
import argparse

SKOOLKIT_HOME = os.environ.get('SKOOLKIT_HOME')
if not SKOOLKIT_HOME:
    sys.stderr.write('SKOOLKIT_HOME is not set; aborting\n')
    sys.exit(1)
if not os.path.isdir(SKOOLKIT_HOME):
    sys.stderr.write('SKOOLKIT_HOME={}; directory not found\n'.format(SKOOLKIT_HOME))
    sys.exit(1)
sys.path.insert(0, SKOOLKIT_HOME)

from skoolkit.image import ImageWriter
from skoolkit.skoolhtml import Frame
from skoolkit.snapshot import get_snapshot
from skoolkit.graphics import Udg as BaseUdg, Frame

parent_dir = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
WOTEF_Z80 = '{}/WayOfTheExplodingFistThe.z80'.format(parent_dir)


class Udg(BaseUdg):
    def __init__(self, attr, data, mask=None, x=None, y=None):
        BaseUdg.__init__(self, attr, data, mask)
        self.x = x
        self.y = y


class WayOfTheExplodingFist:
    def __init__(self, snapshot):
        self.snapshot = snapshot

    def unpack_data(self, address):
        data = []
        while True:
            fetch = self.snapshot[address]
            address += 1
            if fetch == 0 and fetch == self.snapshot[address]:
                break
            if fetch & (1 << 7):
                fetch &= ~(1 << 7)
                count = self.snapshot[address]
                while count:
                    data.append(fetch)
                    count -= 1
                address += 1
            else:
                data.append(fetch)
        return data

    def get_playarea_udgs(self, x, y, w, h, background):
        playarea_udgs = []
        udgs = [[0] * 8] * 0x80

        background_addresses = 0x602B + (background - 1) * 0x12

        attributes = self.unpack_data(self.snapshot[background_addresses + 0x10] + self.snapshot[background_addresses + 0x11] * 0x100)
        for row in range(background_addresses, background_addresses + 0x10, 4):
            for udg in self.get_playarea_udg(
                self.unpack_data(self.snapshot[row + 2] + self.snapshot[row + 3] * 0x100),
                self.snapshot[row + 0] + self.snapshot[row + 1] * 0x100
            ):
                udgs.append(udg)

        for i in range(0x300 - len(udgs)):
            udgs.append([0] * 8)

        pos = 0
        for row in range(y, y + h):
            playarea_udgs.append([])
            for col in range(x, x + w):
                playarea_udgs[-1].append(Udg(attributes[pos], udgs[pos], x=x, y=y))
                pos += 1

        return playarea_udgs

    def get_playarea_udg(self, tiles, udg_base_address):
        udg = []
        for tile in tiles:
            udg_address = tile * 8 + udg_base_address
            udg.append(self.snapshot[udg_address:udg_address + 8])
        return udg


def _do_pokes(specs, snapshot):
    for spec in specs:
        addr, val = spec.split(',', 1)
        step = 1
        if '-' in addr:
            addr1, addr2 = addr.split('-', 1)
            addr1 = int(addr1)
            if '-' in addr2:
                addr2, step = [int(i) for i in addr2.split('-', 1)]
            else:
                addr2 = int(addr2)
        else:
            addr1 = int(addr)
            addr2 = addr1
        addr2 += 1
        value = int(val)
        for a in range(addr1, addr2, step):
            snapshot[a] = value


def run(snafile, imgfname, options):
    snapshot = get_snapshot(snafile)
    _do_pokes(options.pokes, snapshot)
    game = WayOfTheExplodingFist(snapshot)
    x = y = 0
    width, height = 0x20, 0x18

    if options.geometry:
        wh, xy = options.geometry.split('+', 1)
        width, height = [int(n) for n in wh.split('x')]
        x, y = [int(n) for n in xy.split('+')]

    udg_array = game.get_playarea_udgs(x, y, width, height, options.background)
    frame = Frame(udg_array, options.scale)
    image_writer = ImageWriter()
    with open(imgfname, "wb") as f:
        image_writer.write_image([frame], f)


###############################################################################
# Begin
###############################################################################
parser = argparse.ArgumentParser(
    usage='wotefimage.py [options] FILE.png',
    description="Create an image of the background in The Way of the Exploding Fist.",
    formatter_class=argparse.RawTextHelpFormatter,
    add_help=False
)
parser.add_argument('imgfname', help=argparse.SUPPRESS, nargs='?')
group = parser.add_argument_group('Options')
group.add_argument('-b', dest='background', type=int, default=1,
                   help='Which background to generate; 1, 2 or 3 (default: 1)')
group.add_argument('-g', dest='geometry', metavar='WxH+X+Y',
                   help='Create an image with this geometry')
group.add_argument('-p', dest='pokes', metavar='A[-B[-C]],V', action='append', default=[],
                   help="Do POKE N,V for N in {A, A+C, A+2C,...B} (this option may\n"
                        "be used multiple times)")
group.add_argument('-s', dest='scale', type=int, default=2,
                   help='Set the scale of the image (default: 2)')
namespace, unknown_args = parser.parse_known_args()
if unknown_args or not namespace.imgfname:
    parser.exit(2, parser.format_help())
run(WOTEF_Z80, namespace.imgfname, namespace)
