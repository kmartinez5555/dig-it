# dig-it
Designed to be an all-in-one dig for common DNS records with verbose options and prints them in an easy to view format. Currently only available in Linux environment utilizing bash.

To download:

_Assumes ~/Downloads/ will be the target download location. Alter as necessary._
```
git clone https://github.com/kmartinez5555/dig-it.git ~/Downloads/dig-it/
mkdir -p ~/bin/
mv ~/Downloads/dig-it/dig-it.sh ~/bin/
chmod 755 ~/bin/dig-it.sh
```

Once that is completed this should allow $PATH to recognize the command without having to input the file path to call the script. Follow the usage guidlines of the script here:

```
Usage: dig-it [OPTION] [domain]
Options and their usage:
  -b, --basic          Runs only basic DNS checks (A, MX, NS)
  -v, --verbose        Runs a more verbose check of the default values
  -m, --mail           This will check common mail records. Does not
                       DKIM at this time.
  -y, --makeitweird    Checks every type of DNS record I could find that
                       does not require a variable subdomain. May get
                       weirder as I find more.
  -h, --help           well... here we are.
```

New DNS records will be added as it can be determined as universally compatible.
