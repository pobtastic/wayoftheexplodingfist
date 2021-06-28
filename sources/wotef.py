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
from skoolkit.skoolmacro import parse_image_macro, MacroParsingError


class Udg(BaseUdg):
    def __init__(self, attr, data, mask=None, x=None, y=None):
        BaseUdg.__init__(self, attr, data, mask)
        self.x = x
        self.y = y


class WayOfTheExplodingFistHtmlWriter(HtmlWriter):
    def init(self):
        self.font = {c: self.snapshot[0x3C00 + 8 * c:0x3C08 + 8 * c] for c in range(0x20, 0x7A)}

    def expand_shadowbuff(self, text, index, cwd):
        # #SHADOWBUFFbackground[,scale][{X,Y,W,H}](fname)
        end, crop_rect, fname, frame, alt, (background, scale) = parse_image_macro(text, index, (1,), ('id', 'scale'))
        if fname is None:
            raise MacroParsingError('Filename missing: #SHADOWBUFF{}'.format(text[index:end]))
        frame = Frame(lambda: self.get_shadow_buffer_udgs(background), scale, 0, *crop_rect, name=frame)
        return end, self.handle_image(frame, fname, cwd, alt, 'PlayAreaImagePath')

    def expand_background(self, text, index, cwd):
        # #BACKGROUNDid[,scale][{X,Y,W,H}](fname)
        end, crop_rect, fname, frame, alt, (background, scale) = parse_image_macro(text, index, (1,), ('id', 'scale'))
        if fname is None:
            raise MacroParsingError('Filename missing: #BACKGROUND{}'.format(text[index:end]))
        frame = Frame(lambda: self.get_playarea_udgs(background), scale, 0, *crop_rect, name=frame)
        return end, self.handle_image(frame, fname, cwd, alt, 'PlayAreaImagePath')

    def position_data(self, cwd, positioning, tiles, fname, scale=2):
        udgs = []
        for udg in self.get_playarea_udg(
                self.unpack_data(positioning),
                tiles
            ):
            udgs.append(udg)
        frame = Frame(lambda: self.position_create_frame(udgs), scale)
        return self.handle_image(frame, fname, cwd, path_id='PlayAreaImagePath')

    def position_create_frame(self, udgs):
        playarea_udgs = []
        pos = 0
        x = y = 0
        w, h = 0x20, 0x18
        for row in range(y, y + h):
            playarea_udgs.append([])
            for col in range(x, x + w):
                playarea_udgs[-1].append(Udg(56, udgs[pos], x=x, y=y))
                pos += 1
                if pos >= len(udgs):
                    return playarea_udgs
        

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

    def get_shadow_buffer_udgs(self, background):
        x = y = 0
        w, h = 0x20, 0x0D

        playarea_udgs = []
        udgs = []

        background_addresses = 0x602B + (background - 1) * 0x12

        for row in range(background_addresses, background_addresses + 0x10, 4):
            for udg in self.get_playarea_udg(
                self.unpack_data(self.snapshot[row + 2] + self.snapshot[row + 3] * 0x100),
                self.snapshot[row + 0] + self.snapshot[row + 1] * 0x100
            ):
                udgs.append(udg)

        pos = 0
        for row in range(y, y + h):
            playarea_udgs.append([])
            for col in range(x, x + w):
                playarea_udgs[-1].append(Udg(56, udgs[pos], x=x, y=y))
                pos += 1

        return playarea_udgs

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

    def get_key(self, cwd, msb, lsb):
        key_map = {}
        key_map[0xFE] = {
            0x01: "SHIFT",
            0x02: "Z",
            0x04: "X",
            0x08: "C",
            0x10: "V",
        }
        key_map[0xFD] = {
            0x01: "A",
            0x02: "S",
            0x04: "D",
            0x08: "F",
            0x10: "G",
        }
        key_map[0xFB] = {
            0x01: "Q",
            0x02: "W",
            0x04: "E",
            0x08: "R",
            0x10: "T",
        }
        key_map[0xF7] = {
            0x01: "1",
            0x02: "2",
            0x04: "3",
            0x08: "4",
            0x10: "5",
        }
        key_map[0xEF] = {
            0x01: "0",
            0x02: "9",
            0x04: "8",
            0x08: "7",
            0x10: "6",
        }
        key_map[0xDF] = {
            0x01: "P",
            0x02: "O",
            0x04: "I",
            0x08: "U",
            0x10: "Y",
        }
        key_map[0xBF] = {
            0x01: "ENTER",
            0x02: "L",
            0x04: "K",
            0x08: "J",
            0x10: "H",
        }
        key_map[0x7F] = {
            0x01: "SPACE",
            0x02: "FULL-STOP",
            0x04: "M",
            0x08: "N",
            0x10: "B",
        }
        return key_map[msb][lsb]

    def get_kempston(self, cwd, msb, lsb):
        key_map = {
            0x01: "RIGHT",
            0x02: "LEFT",
            0x04: "DOWN",
            0x08: "UP",
            0x10: "FIRE",
        }
        return key_map[lsb]
