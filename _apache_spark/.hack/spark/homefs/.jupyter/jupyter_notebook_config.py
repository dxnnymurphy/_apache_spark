import os
from notebook.auth import passwd

c.JupyterApp.answer_yes = True
c.NotebookApp.allow_origin = '*'
c.NotebookApp.allow_remote_access = True                                                                                                                                       
c.NotebookApp.allow_root = True
c.NotebookApp.base_url = '/proxy/app/jupyter/'
c.NotebookApp.disable_check_xsrf = True
c.NotebookApp.ip = '0.0.0.0'
c.NotebookApp.notebook_dir = os.path.expanduser('~/.danny/var/workspace/jupyter')
c.NotebookApp.open_browser = False
c.NotebookApp.password = passwd(os.getenv('JUPYTER_NOTEBOOK_PASSWORD'))
c.NotebookApp.password_required = True
c.NotebookApp.port = 8888
c.NotebookApp.token = ''
c.NotebookApp.tornado_settings = { 'static_url_prefix': '/proxy/app/jupyter/static/' }
c.MultiKernelManager.default_kernel_name = 'danny'
c.FileContentsManager.allow_hidden = True
