# Copyright 2021 Paul Maddern
#
# This program is free software: you can redistribute it and/or modify it under
# the terms of the GNU General Public License as published by the Free Software
# Foundation, either version 3 of the License, or (at your option) any later
# version.
#
# This program is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE. See the GNU General Public License for more
# details.
#
# You should have received a copy of the GNU General Public License along with
# this program. If not, see <http://www.gnu.org/licenses/>.

from skoolkit.graphics import Frame, Udg as BaseUdg
from skoolkit.skoolhtml import HtmlWriter
from skoolkit.skoolmacro import parse_image_macro


class Udg(BaseUdg):
    def __init__(self, attr, data, mask=None, x=None, y=None):
        BaseUdg.__init__(self, attr, data, mask)
        self.x = x
        self.y = y


class WayOfTheExplodingFistHtmlWriter(HtmlWriter):
    def init(self):
        self.font = {c: self.snapshot[0x3C00 + 8 * c:0x3C08 + 8 * c] for c in range(0x20, 0x7A)}

    def background(self, cwd, fname, background=1, scale=2):
        frame = Frame(lambda: self.get_playarea_udgs(background), scale)
        return self.handle_image(frame, fname, cwd, path_id='PlayAreaImagePath')

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

    def get_playarea_udgs(self, background):
        x = y = 0
        w, h = 0x20, 0x18

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
