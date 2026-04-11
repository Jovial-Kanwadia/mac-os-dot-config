# AI Git Commit Hook (Gemini) -- Global Setup Guide for macOS

This guide shows how to install an **AI-powered Git commit message
generator** globally on macOS using a `prepare-commit-msg` hook and the
Gemini API.

Once installed, every time you run:

    git commit

Git will automatically:

1.  Read your staged changes
2.  Send them to Gemini
3.  Generate a **Conventional Commit message**
4.  Insert it into the commit editor

------------------------------------------------------------------------

# 1. Install Dependencies

macOS already includes `curl`, but you must install `jq`.

Install Homebrew if you don't have it:

    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

Then install jq:

    brew install jq

------------------------------------------------------------------------

# 2. Create a Global Git Hooks Directory

    mkdir -p ~/.githooks

------------------------------------------------------------------------

# 3. Create the Hook File

Open the hook file:

    nano ~/.githooks/prepare-commit-msg

Paste your **AI commit hook script** into this file.

Save and exit:

    CTRL + O
    ENTER
    CTRL + X

------------------------------------------------------------------------

# 4. Make the Hook Executable

Git will ignore the hook if it isn't executable.

    chmod +x ~/.githooks/prepare-commit-msg

------------------------------------------------------------------------

# 5. Tell Git to Use Global Hooks

Configure Git to use your new hooks directory:

    git config --global core.hooksPath ~/.githooks

Verify it:

    git config --global core.hooksPath

Expected output:

    /Users/yourname/.githooks

------------------------------------------------------------------------

# 6. Add Your Gemini API Key

Create a secure key file:

    nano ~/.gemini_api_key

Paste your API key:

    YOUR_GEMINI_API_KEY_HERE

Save and exit.

Secure the file:

    chmod 600 ~/.gemini_api_key

------------------------------------------------------------------------

# 7. Test the Hook

Create a test repository or use an existing one.

Example:

    mkdir test-ai-commit
    cd test-ai-commit
    git init

Create a file:

    touch hello.txt
    git add .

Run commit:

    git commit

The hook should generate something like:

    chore: add hello.txt

------------------------------------------------------------------------

# 8. Debugging

Check that Git sees the hook:

    ls ~/.githooks

You should see:

    prepare-commit-msg

Check permissions:

    ls -l ~/.githooks/prepare-commit-msg

Should show:

    -rwxr-xr-x

If not:

    chmod +x ~/.githooks/prepare-commit-msg

------------------------------------------------------------------------

# 9. Optional: Add a Faster Commit Alias

Add a Git shortcut:

    git config --global alias.ac "!git add -A && git commit"

Now you can run:

    git ac

Which will:

1.  Stage all files
2.  Generate an AI commit message
3.  Commit automatically

------------------------------------------------------------------------

# Result

You now have a **global AI commit assistant** for every Git repository
on your Mac.

Workflow:

    edit code
    git add .
    git commit

And the commit message is automatically generated.

------------------------------------------------------------------------

# Notes

-   Works in **any Git repository**
-   Requires **internet access for Gemini API**
-   Commit messages follow **Conventional Commits**
