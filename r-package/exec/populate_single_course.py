#!/opt/conda/envs/mooc/bin/python

import os
import subprocess
import json
import click as cl
from datetime import datetime


@cl.command()
@cl.option("--overwrite", default=True)
def populate(overwrite):
    start_time = datetime.now()
    command = "bash ./populate_course.sh {short_name} {big_table} {gcloud}".format(
                short_name="add_shortname_here",
                big_table="add_big_table_name_here",
                gcloud="add_gcloud_name_here")
    if overwrite:
        command = "{} --overwrite=true".format(command)
    print(command)
    subprocess.call(command, shell=True)
    write_hashed_courses()
    print("Total time " + str((datetime.now() - start_time).seconds) + " seconds")


def write_hashed_courses():
    subprocess.call('Rscript write_hashed_courses.R', shell=True)


if __name__ == '__main__':
    os.chdir(os.path.dirname(os.path.abspath(__file__)))
    populate()
