# Immutablue Custom

> "Gotta shell on this thang!"

A forkable repo that you can use to create a custom build of [Immutablue](https://gitlab.com/immutablue/immutablue)


## Getting started
- Fork this repo to your git provider of choice.
- Find `change-me` in `Makefile` and `Containerfile` and update them using your container registry and project name of choice (probably from your git provider but doesn't have to be).
- Have a look at `packages/packages.custom-50-example.yaml` and `packages/template.packages.custom-00-template.yaml`. Copy the latter to a new file, or make tweaks to the formal.
    - The syntax overall should be straight forward, there are comments that are should describe things and what they do.
    - If there are questions open an issue.
- Add anything you want into `post_install.sh` for your customization. Such as pulling in your dotfiles for your user, cloning repos, etc.
- Run `make build` and follow rebasing below


## Rebasing
- Rebase an [Immutablue](https://gitlab.com/immutablue/immutablue) instance to your build with `make rebase` from your repo.
- After first boot be sure to run `immmutablue install`


## Updating 
- `immutablue update`


## FAQs
- Help, I broke a distrobox container. How do I fix it?
    - The beautiful thing about having things declared as code is you can just nuke it and remake it: `distrobox rm -f <name>` then follow up with `immutablue update`
- How do I get started 
    - Have a look at the source and the comments for the files here
- I forked this repo, but you made changes how can I get them?
    - Set up an upstream origin in git: 
```
git remote add upstream https://gitlab.com/immutablue/immutablue-custom.git
git fetch upstream 
git rebase upstream/master
```
