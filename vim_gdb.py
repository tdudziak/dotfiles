from __future__ import print_function, division
from subprocess import check_output
import random, os


class VimGdbServer(object):
    def __init__(self):
        import vim
        self.vim = vim
        vim.command(':sign define gdb_pc text=>> texthl=Search')
        self._id = None

    def ensure_opened(self, file_name):
        if not os.path.exists(file_name):
            raise self.vim.error()
        # TODO: jump to a window with file_name already opened
        # TODO: maintain a tab and window to display everything in?
        self.vim.command(':badd %s' % file_name)

    def on_stop(self, file_name, line_number):
        new_id = random.randint(100, 20000)
        try:
            self.ensure_opened(file_name)
            self.vim.command(':sign place %d line=%d name=gdb_pc file=%s' %
                                (new_id, line_number, file_name))
        except self.vim.error:
            new_id = None
        if self._id is not None:
            self.vim.command(':sign unplace %d' % self._id)
        self._id = new_id
        if self._id is not None:
            self.vim.command(':sign jump %d file=%s' % (self._id, file_name))


class VimGdbClient(object):
    def __init__(self):
        import gdb
        self.gdb = gdb
        gdb.events.stop.connect(self.on_stop)

    def send(self, method, *args):
        cmd = ':py3 vim_gdb_server.%s(%s)<Enter>' % (method, ', '.join(repr(x) for x in args))
        check_output(['gvim', '--remote-send', cmd])

    def on_stop(self, event):
        frame = self.gdb.selected_frame()
        lineobj = self.gdb.find_pc_line(frame.pc())
        symtab = lineobj.symtab
        if symtab is not None:
            self.send('on_stop', symtab.fullname(), lineobj.line)


try:
    vim_gdb_server = VimGdbServer()
except ImportError:
    pass
try:
    vim_gdb_client = VimGdbClient()
except ImportError:
    pass
