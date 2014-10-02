# "opt-pyenv" Omnibus Package for Python 2.6, 2.7 and 3.3

[pyenv](https://github.com/yyuu/pyenv) is a program to automate the building and installation of various Python versions,
independent of the version that comes with your system.
Typical use-cases are unit-testing and building artifacts for different Python versions
on a single machine / in a single Jenkins job.
`pyenv` supersedes the now *deprecated* “pythonbrew” project.

The following shows how you can use the package once it's built and installed,
followed by a description of the build process.


## Using pyenv

The package installs to `/opt/pyenv`, and the commands offered by the contained Python interpreters
are exposed in `/opt/pyenv/bin`. See the following use-cases on what you can do with those.


## Sample use-cases

### Directly calling a specific Python interpreter

You can add the full path to a specific Python binary to your scripts, e.g.

    #! /opt/pyenv/bin/python3
    import os, sys
    print("You called {0}".format(os.path.realpath(sys.executable)))

which will print

    You called /opt/pyenv/.pyenv/versions/3.3.2/bin/python3.3

You cannot and shouldn't install additional site-packages into these installations,
see the following section on how to deal with projects that go beyond simple scripts
and have 3rd party dependencies.


### Creating a virtualenv for a specific Python interpreter

Just call `/opt/pyenv/bin/virtualenv-VVV` to create a [virtualenv](http://www.virtualenv.org/) for the chosen version.
At the moment, you can choose between `2.6`, `2.7`, and `3.3`, or else just use the major version `2` or `3`.

Try

    venv=/tmp/pyvenv-$USER
    /opt/pyenv/bin/virtualenv-3 --clear $venv
    $venv/bin/pip install markdown2
    $venv/bin/markdown2 <<<'# Hello, World!'

which will print

    <h1>Hello, World!</h1>

Since Python3 has its own virtualenv integrated, an alternative command to call is `/opt/pyenv/bin/pyvenv-3`.
However, such virtualenvs come bare and without `pip` –
you have to [get-pip](http://pip.readthedocs.org/en/latest/installing.html#install-pip) one into them.


## Building the pyenv package

**TODO**