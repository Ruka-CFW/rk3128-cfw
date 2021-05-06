# Contributing

* [Definitions](#definitions): **please this section first**.
* [Branch Policy](#branch-policy): describes the project's branching strategy.
* [Contribution Guidelines](#contribution-guidelines): describes how to send a contribution to the project.
* [Additional Documentation](#additional-documentation): some extra stuff that may be worth reading before start working on your contribution.

## Definitions

#### Upstream
The main Git repository of the project (this is not the same as the `main` branch). It is common to fork a project to send contributions (see [Contribution Guidelines](#contribution-guidelines) section). Those forks need to be aligned with the upstream repository.

#### Clean merge
A merge that is performed on a branch, without any other merges in between. Next screenshot shows what IS NOT a clean merge and therefore we get a dirty Git graph. It's difficult to see the scope of each change and rolling back can be nightmare:

![Clean and clear merge seen from `git log --graph --oneline`](doc/assets/img/unclean-merge-log.png)

## Branch Policy

The main ideas behind the branching strategy explained here are:
* Keep things as simple as possible.
* The contributors are fully responsible of their changes.
* Users are expected to use the latest version released.

By following these ideas, the project `main` branch is the place to go to get the latest changes. Some of them could be still under testing processes. This means `main` is as stable as the testing performed on each Pull Request before merging it into master. It is granted that those changes are part of the roadmap (in other words, may not be fully tested but they are not experimental).

For more stable versions, we use tags and releases. Each release is associated to a tag in the repository, so it's easy to get the snapshot of each release if needed.

In case of a bug, it will be fixed on the current `main` branch and not backported. Users are expected to be always in the latest release, supporting several versions at a time is out of the current possibilities of the project in terms of effort.

**Corner case**: if a bug broke an older version and there were not any possibility of updating from that version to a newer one for a representative number of users, a branch would be created from that point, the fix would be applied on that branch and then merged into the `main` branch. The branch created for the fix is expected to be deleted as soon as users of that branch are able to update to the latest release.

**Experimental development**: sometimes it is needed to break everything to explore new options for future releases (always under the roadmap of the project) while some developments for the next one are still being tested and pending to be merged. In those cases, a new branch will be created until `main` branch gets to a specific release point. At that point the new branch will be reintegrated into `main`.

This means that most of the time there will be just one or two branches upstream, the rest will be part of the contributors' forks.


## Contribution Guidelines

General GitHub workflow rules for contributing via fork apply to our project.

On top of those, the following is a quick reference of the steps ([see also an example of the process](doc/pull_request_example.md)):

* Fork the project. See [GitHub documentation on forking a repo](https://docs.github.com/en/github/getting-started-with-github/fork-a-repo)). Make sure you configure the upstream repo as a remote so you will be able to fetch newer changes from upstream later on, if needed.
* Create a local branch (`git checkout -b <branch_name>`).
* Make your changes. Please, follow the [Additional Documentation](#additional-documentation). **If you plan to add new files to the documentation** folder, please follow the [template document](doc/_template.md) included in the `doc` folder.
* Push your local branch to your fork (not to upstream, in the worst case you won't have push permission upstream and will get an error, unless you are a trusted committer, in which case please double check your command line).
* Go to GitHub, create the Pull Request. See [GitHub documentation on how to create a Pull Request from a fork](https://docs.github.com/en/github/collaborating-with-issues-and-pull-requests/creating-a-pull-request-from-a-fork).
  * The contributor is responsible of providing commits that allow [clean merges](#clean-merge). In case this not happens, they were requested by the reviewers to rebase their branch and push again the changes.
* Reviewer is responsible of merging changes, even if the contributor has permissions to do it. Merges should look like the following one (obtained via `git log --graph --oneline` command):
![Clean and clear merge seen from `git log --graph --oneline`](doc/assets/img/merge-log.png)
* From the image, is clear:
  * Where the merge was performed.
  * Who merged the changes (not in the image because `--oneline` option was used to summarize the resulting graph).
  * The commits being merged.
  * Who sent those commits (not in the image because `--oneline` option was used to summarize the resulting graph).
  * Ideally only one feature is covered by all of them, no matter if it's split into several commits for clarity, because the tree is clear enough thanks to its shape.

## Additional Documentation
In addition to all of the above mentioned, we encourage you to read the following guides before start contributing:

* [How to Write a Git Commit Message](https://chris.beams.io/posts/git-commit/). Commit messages matter. Here's how to write them well. Written by Chris Beams.
* [Git Branching - Branches in a Nutshell](https://git-scm.com/book/en/v2/Git-Branching-Branches-in-a-Nutshell). From [Pro Git book](https://git-scm.com/book/en/v2), written by Scott Chacon and Ben Straub and published by Apress. All content is licensed under the Creative Commons Attribution Non Commercial Share Alike 3.0 license.
* [Git happens! 6 Common Git mistakes and how to fix them](https://about.gitlab.com/blog/2018/08/08/git-happens/). Written by Sam Beckham.
