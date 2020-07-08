<p align="center">
  <a href="http://gitron.herokuapp.com"><img src="http://i.imgur.com/6BG1Msb.png" alt="gitron logo" /></a>
</p>

# Gitron

>Greetings, programs!

Have you ever wondered how your *github repository* would look like on a **TRON grid**?

## Description

This is a web game based on [TRON](http://en.wikipedia.org/wiki/Tron) universe. Every repository on GitHub can be a TRON character *(sam, clu, flynn, tron, etc.)* and can fight against other repositories.

The score is based on:

* repository size
* number of releases
* number of contributors

**issues** instead will be subtracted to the main score of your repository.
The avatar is generated based on your repository **stars**, more stars it gets more important is the character generated :sunglasses:

Winner is chosen according to the higher score of the two programs fighting.

Beware the program who loses will be subject to immediate **deresolution**!

![sark](http://i.imgur.com/3llHbBR.gif)

## Achievements

These are just a few achievements you can unlock in **Gitron**.

Achievement | Description
----------- | -----
THE GRID | Enter The Grid
FOUND ZUSE | Find a way to see Zuse *(the guy with the white hair)*
ISOMORPHIC | Discover and ISO
PURGE | Dereze an ISO
TRON LIVES | Is Tron still alive?
FAITH IN USERS | Dereze the poor Jarvis
BETRAYAL | When Clu 2 derezzed Tron
END OF LINE | Destroy Master Control Program
THE CREATOR | ???

## Assets

Check out :zap: [THIS](https://github.com/syxanash/gitron/blob/master/public/img/ASSETS.md):zap: page for awesome pixel art!

![fight](http://i.imgur.com/q6kaw2f.gif)

## Installation

This app is written in Ruby using Sinatra.

```
gem install octokit
git clone git://github.com/syxanash/gitron
bundle install
ruby app.rb
```

## See also

Here listed a few things I used for developing this project.

* [github-high-scores](https://github.com/leereilly/github-high-scores) by Lee Reilly. I was highly inspired by his work.
* [Sinatra](http://www.sinatrarb.com/) a Ruby web framework
* [noty](https://github.com/needim/noty) jquery notification plugin
* [magic](https://github.com/miniMAC/magic) a couple of very nice CSS3 animations I used
* [github API](https://developer.github.com/v3/)

## Bugs & known issues

* __MCP__ apparently is still alive...

## Easter eggs

:rabbit:

* look up for the source code if you're interested

## About

This is just a summer project I developed after finishing a few exams for university. I really hope you like it as much as I liked creating it!

Let's see if your programs are lucky enough to fight for his own user.

![clu2](http://media.giphy.com/media/IRSvFo1FIXuTK/giphy.gif)
