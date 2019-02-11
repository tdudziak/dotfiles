from __future__ import print_function, division
from subprocess import check_output
import random, os


class VimWindowContext(object):
    def __init__(self, window):
        import vim
        self.vim = vim
        self._window = window
        self._old_window = vim.current.window
        self._switch_to(window)

    def _switch_to(self, window):
        tab = window.tabpage
        self.vim.command(':tabnext %d' % tab.number)
        self.vim.command(':%dwincmd w' % window.number)

    def __enter__(self):
        return self

    def __exit__(self, type, value, tb):
        self._switch_to(self._old_window)


class VimGdbServer(object):
    def __init__(self):
        import vim
        self.vim = vim
        vim.command(':sign define gdb_pc text=>> texthl=Search')
        self._id = None
        self._dbg_win = None
        self._dbg_tab = None

    def _open_dbg_win(self):
        if self._dbg_win is not None and self._dbg_win.valid:
            return self._dbg_win
        self.vim.command(':$tabnew')
        self._dbg_tab = list(self.vim.tabpages)[-1]
        self._dbg_win = self._dbg_tab.windows[0]
        return self._dbg_win

    def _try_command(self, *args, **kwargs):
        try:
            return self.vim.command(*args, **kwargs)
        except vim.error:
            pass

    def on_stop(self, file_name, line_number):
        new_id = random.randint(100, 20000)
        with VimWindowContext(self._open_dbg_win()):
            self._try_command(':edit %s' % file_name)
            self._try_command(':sign place %d line=%d name=gdb_pc file=%s' %
                                (new_id, line_number, file_name))
            if self._id is not None:
                self._try_command(':sign unplace %d' % self._id)
            self._id = new_id
            self._try_command(':sign jump %d file=%s' % (self._id, file_name))


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
