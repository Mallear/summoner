# coding: utf-8
import subprocess
import click
import git
import yaml
import os
import os.path as osp
from pathlib import Path
import docker

docker_watcher = docker.from_env()
repo_base_url='https://gitlab.com/summoner/'
config_file='config.yml'


class Summoner:

    def __init__(self):
        with open(config_file, 'r') as stream:
            cfg = yaml.load(stream)
            self.version = cfg['summoner']['version']
            self.domain = cfg['summoner']['domain']
            self.installDirectory = cfg['summoner']['install_dir']
            self.minionsDirectory = cfg['summoner']['minions_dir']
            self.proxyType = cfg['summoner']['reverse_proxy']
            self.applications = []
            if cfg['summoner']['applications'] is not None:
                for app in cfg['summoner']['applications']:
                    self.applications.append(app)


summoner = Summoner()


@click.group()
def cli():
    pass


@cli.command()
def init():
    click.echo('Init Summoner')
    click.echo('Cloning from Gitlab ...')
    main_module = 'summoner'

    # Check path
    path = Path(summoner.installDirectory)
    if not path.exists():
        # Clone git repo
        repo = git.Repo.clone_from(repo_base_url + main_module, osp.join(summoner.installDirectory), branch='dev')
        click.echo('Summoner cloned !')
    else:
        click.echo('Summoner already installed.')

    # Set up docker master network
    if len(docker_watcher.networks.list(names=['master'])) == 0:
        docker_watcher.networks.create('master')

    click.echo('Installing applications from configuration file ...')
    # Set up minion directory
    minion_path = Path(summoner.minionsDirectory)
    if not minion_path.exists():
        minion_path.mkdir()

    # Set up reverse proxy
    deploy(summoner.proxyType)
    # Start apps
    for app in summoner.applications:
        deploy(app)


# Add volume recovering when deployed
def deploy(app):
    assert app is not None
    click.echo('Starting '+app)
    minion_dir = summoner.minionsDirectory+'/'+app
    minion_path = Path(minion_dir)
    # Clone from repo
    if not minion_path.exists():
        git.Repo.clone_from(repo_base_url + app + '.git', osp.join(minion_dir), branch='master')
    else:
        click.echo('Minion already clone from repository')
    # Generate .env file from .env_default
    script = minion_dir+'/'+'deploy.py'
    os.chdir(minion_dir)
    Path(script).chmod(0o755)
    subprocess.run(["python", script, summoner.domain], stdout=subprocess.PIPE)
    os.chdir(summoner.installDirectory)
    click.echo('Minion launched.')


@cli.command()
@click.argument('app')
def start(app):
    deploy(app)


# Todo : add volume auto save when stopped
@cli.command()
@click.argument('app')
def stop(app):
    assert app is not None
    click.echo('Stopping '+app)
    minion_dir = summoner.minionsDirectory+'/'+app
    minion_path = Path(minion_dir)
    if not minion_path.exists():
        click.echo('Minion do not exist.')
    else:
        if len(docker_watcher.containers.list(filters={'name': app+'-'+summoner.domain})) != 0:
            os.chdir(minion_dir)
            subprocess.call("docker-compose down", shell=True)
            os.chdir(summoner.installDirectory)
            click.echo('Minion stopped.')
        else:
            click.echo('Minion is not deployed yet.')


@cli.command()
@click.argument('app')
def update(app):
    stop(app)
    start(app)


# Print all running containers
@cli.command()
def ls():
    for container in docker_watcher.containers.list():
        click.echo(container.name.split("-")[0])


cli.add_command(init)
cli.add_command(start)
cli.add_command(stop)
cli.add_command(update)
cli.add_command(ls)

if __name__ == "__main__":
    cli()
