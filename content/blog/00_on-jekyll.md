Title: On getting started with Jekyll
Lang: EN
Date: 2017-10-20 18:01:00 -0600
Category: Getting Started
Tags: jekyll; gh-sites; tutorial
Slug: on-jekyll
Authors: Diego Quintana
Summary: ruby's static site generator
Status: published

<!-- Summary:  -->
<!-- Modified: 2010-12-05 19:30 -->

I've decided to start a blog, (again, for the _nth_ time) and this time I am giving a try on [jekyll](https://jekyllrb.com/) and the [github pages](https://pages.github.com), since they seem to do quite a fine job.

Setting things up was easy. I'm not going to copy and paste the guides already present in both sites, since it won't add anything. Instead I will try to share a bit of the troubleshooting I had to do during the process.

# First steps

Okay, it took me about nothing to have my site showing a humble *Hello World* in my ```index.html``` on my site.

## Creating your personal page

You can create a site for yourself or for some repo you own. I'm dealing with the first case for now: A site for myself.

Long story short, what I did was:

1.  Have a [Github](https://github.com) account. _Duh_. Then create a repo named *[**your username**].github.io*. In my case, my username is *diegoquintanav*. You can change that later, it seems. Let's not care about that *for now*.
2.  Add a file named ```index.html``` in the root folder of the repo, and write *Hello World* in it.
3.  ???
4.  Profit! go to *[**your username**].github.io* and you should be able to see the words too.

That was a piece of cake. Next thing you can do is to set up **Jekyll**. This requires a bit more of work, but don't be scared.
Before doing anything, I believe it's a good thing to understand *why* should you use **Jekyll** and not just plain HTML or **Wordpress** for this matter. Since this is a personal issue and a matter of preference, I can only share my experience and talk about my needs.

I tried using Wordpress, which has a lot of resources to get up and running right out of the box. It is also free, which is nice. In my case, I wanted to have more control over the stuff I was writing, namely be able to deploy my stuff whenever I want and to be able to change stuff from the very core, so to speak. Plus, this should work as a first experience running a site. Github pages may be too *vanilla* for the hardcore developer, but is a very balanced solution for enthusiasts like me.

Now there are two ways it seems, to get started. The first one implies creating the folder structure manually, and this process is more or less explained in [this fine post](http://jmcglone.com/guides/github-pages/) which is also referenced by the **Jekyll** site.

What I didn't like about the post, though, is that doing things manually usually imply forgetting about things. I prefer to stick with the solution using **Bundle** and **Jekyll** from the terminal, which is more or less described [here](https://jekyllrb.com/docs/installation/) and [here](https://jekyllrb.com/docs/quickstart/).

## Issues

### New posts are not being displayed
 If you deployed **Jekyll** correctly, it should use the ```minima``` template by default. You should be able to add more posts inside the folder ```_posts``` and see them instantly on your ```localhost```. That didn't happen in my case. A short way to debug this issue that solved my problem required the ```--verbose``` flag when firing up the service.

```bash
$ sudo bundle exec jekyll serve --verbose
  Logging at level: debug
Configuration file: /home/diego/Documents/diegoquintanav.github.io/_config.yml
  Logging at level: debug
         Requiring: jekyll-feed
         Requiring: kramdown
            Source: /path/to/diegoquintanav.github.io
       Destination: path/to/diegoquintanav.github.io/_site
 Incremental build: disabled. Enable with --incremental
      Generating...
       EntryFilter: excluded /Gemfile
       EntryFilter: excluded /Gemfile.lock
           Reading: _posts/2017-10-27-on-jekyll.md
           Reading: _posts/2017-10-26-welcome-to-jekyll.markdown
          Skipping: _posts/2017-10-27-on-jekyll.md has a future date
        Generating: JekyllFeed::Generator finished in 0.000744857 seconds.
...
```

In line ```15``` you can observe the ``` Skipping: _posts/2017-10-27-on-jekyll.md has a future date```. Changing the date solved the problem. About the ```sudo``` thing, consider it a malpractice. The ruby environment manager [```rbenv```](https://github.com/rbenv/rbenv) fought bravely against the [Anaconda's](https://anaconda.org/) ```gcc``` dependencies and I just could not manage to have a ruby instance outside of ```root```. *Sorry*.

Other reasons may involve a bad filename formatting or the presence of colons ```:``` in it. You can read more about this [here](https://stackoverflow.com/questions/30625044/jekyll-post-not-generated).

### Using Latex equations

This was not trivial for me. If you follow the [guidelines](https://jekyllrb.com/docs/extras/) inside the documentation, you should end in the tutorial.

It should be something easy. Copying and pasting the CDN in the ```<head>``` of the document. *But where is this file?*

This was not obvious to me.

After some _google-fu_, nothing was explicit enough to me. [This post](https://github.com/mmistakes/minimal-mistakes/issues/735) helped a bit, but after realizing that the docs were not good enough, I ended up in ```#jekyll``` on [freenode](https://freenode.net/).

With a bit of help of some nice anons, I found out that

1.  Themes are either *Gem-installed* or locally installed. By default after deploying Jekyll, you should be using ```Minima``` as a *Gem Theme*. This means basically that the files that compose your theme live somewhere else. Run ```bundle show minima```, which  displays the path of the theme. Somewhere inside ```var``` if you are using Ubuntu. If you ```cd``` into that folder you should see some folders, namely ```_layouts```, which are the templates of the theme and ```_includes``` which I'm not sure yet. Every theme has more or less the same folders with the *exact* names, but the way pages are composed by means of templates should differ. Expect that.

2.  Inside the ```_layouts``` folder you should find ```head.html```. Copy that file inside your own project, in a folder called ```_layouts``` if you don't have it yet. By doing this you are basically overriding the base files inside the *Gem theme* with your own.

3.  Now you can edit it. Copy the script node from the extras site on Jekyll and there you go. You should be able to render$ \LaTeX$ equations easily.
    *  Please beware that in comparison to the traditional way, *inline equations* and almost every equation is rendered using doble dollar signs i.e.

```latex
$$\text{A } \LaTeX \text{ equation.}$$
```

$$\text{A } \LaTeX \text{ equation.}$$

Other implementation details depend on the Markdown compiler being used, in my case (and odds that yours too if you are starting with jekyll) I'm using [kramdown](https://kramdown.gettalong.org/syntax.html#math-blocks) which is set by default.

# Next Steps

I think there are a lot of other things to play around, which I will document and comment in the future posts. Not yet. This is my *MVP* for now. Next iteration should include:

*  Comments section. Might prove useful somewhere.
*  Add more sections, editing the ```navbar``` or something equivalent. Add more endpoints.
*  Change the site's domain.
*  Add some google analytics sorcery or equivalent.
*  Theme editing and/or theme changing
*  Add embedded python REPL instances. I saw them somewhere on the internet. I want them.




