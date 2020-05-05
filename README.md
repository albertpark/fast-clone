# git-fast-clone - Clone repository faster

## Introduction

This script will help you clone a repository without having to input the full url.

## Usage

Pull the file from the repository:
```bash
$ git clone https://github.com/albertpark/fast-clone.git
```

Here is the help menu:
```bash
$ cd fast-clone
$ ./git-fast-clone.sh --h
Clone from a repository faster.
Note: The argument order does not matter.
Options:
    -u <user> Username of the repository
   --user <user>
    -r <repo> Name of the git repository
   --repo <repo>
    -d <directory> Desired directory name to place the git location
   --dir <directory>
   --git      Use git connection
   --ssl      Use https connection (default is git)
```

Now go to your desired directory to set up multiple remote servers and run the script by replacing the `<username>` and `<repo>` to your username and repository name:

```bash
$ fast-clone/git-fast-clone.sh -u <username> -r <repo>
```

The `--ssl` flag is optional and will set the remote with a `HTTPS` connection. The default connection will be `SSH` (`git`). When `<directory>` is not configured or defined the script will use the repository name as the default directory name.

## Configuration

Included a configuration file to setup multiple remote servers and username including ssl connection in `remote.conf`:
```
# Set ssl connection
CONFIG.ssl=true

# Set uername and repository
CONFIG.user=albertpark
CONFIG.repo=fast-clone
```
Note: Options passed in the arguments will override the configuration settings.

## License

MIT

