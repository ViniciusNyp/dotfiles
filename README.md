# Dotfiles

This repository contains my personal dotfiles. These dotfiles are managed using a bare Git repository.

## Installation

To install the dotfiles, follow these steps:

1. Clone this repository to your local machine:

    ```sh
    git clone --bare https://github.com/ViniciusNyp/dotfiles $HOME/.dotfiles
    ```

2. Define an alias for the dotfiles repository:

    ```sh
    alias dotfiles='/usr/bin/git --git-dir=$HOME/.dotfiles --work-tree=$HOME'
    ```

3. Configure the dotfiles repository to not show untracked files:

    ```sh
    dotfiles config --local status.showUntrackedFiles no
    ```

4. Checkout the dotfiles:

    ```sh
    dotfiles checkout
    ```

    If you encounter any errors, make sure your home directory is clean and try again.

5. Set up the dotfiles repository to track the remote branch:

    ```sh
    dotfiles branch --set-upstream-to=origin/main main
    ```

6. Pull the latest changes:

    ```sh
    dotfiles pull
    ```
    
## Usage

To manage your dotfiles, use the `dotfiles` alias defined above. Here are some common commands:

- Add a new dotfile:

    ```sh
    dotfiles add <file>
    ```
    
- Add all already tracked dotfiles:

  ```sh
  dotfiles add -u
  ```

- Commit changes:

    ```sh
    dotfiles commit -m "Commit message"
    ```

- Push changes to the remote repository:

    ```sh
    dotfiles push
    ```

- Pull changes from the remote repository:

    ```sh
    dotfiles pull
    ```
