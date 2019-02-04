#!/usr/bin/env python

import sys
import os
import logging
import argparse

from pandas import read_csv

LOG_LEVELS = ['DEBUG', 'INFO', 'WARNING', 'ERROR', 'CRITICAL']

class App(object):
    def __init__(self, args=None, logger=None):
        self.logger = logger
        self.ifile = args.input_tsv_file
        self.ofile = args.output_excel_file if args.output_excel_file else "{}.{}".format(os.path.splitext(self.ifile)[0], 'xlsx')
        self.engine = args.engine
        self.delimiter = args.delimiter
        
    def run(self):
        self.logger.info("Reading {}".format(self.ifile))
        df = read_csv(self.ifile, delimiter=self.delimiter, header=0)
        self.logger.info("{} x {} table".format(df.shape[0], df.shape[1]))
        self.logger.info("Writing {}".format(self.ofile))
        df.to_excel(self.ofile, index=False, engine=self.engine, float_format="%.8f")


def a_logger(name, level="WARNING", filename=None, mode="a"):
    log_format = '%(asctime)s|%(levelname)-8s|%(name)s |%(message)s'
    log_datefmt = '%Y-%m-%d %H:%M:%S'
    logger = logging.getLogger(name)
    if not isinstance(level, int):
        try:
            level = getattr(logging, level)
        except AttributeError:
            raise ValueError("unsupported literal log level: %s" % level)
        logger.setLevel(level)
    if filename:
        handler = logging.FileHandler(filename, mode=mode)
    else:
        handler = logging.StreamHandler()
    formatter = logging.Formatter(log_format, datefmt=log_datefmt)
    handler.setFormatter(formatter)
    logger.addHandler(handler)
    return logger

def make_parser():
    parser = argparse.ArgumentParser(description='Convert tabular file to Excel format')

    parser.add_argument('--input_tsv_file', '-i', metavar="PATH", required=True, 
                        help='tsv input file')

    parser.add_argument('--output_excel_file', '-o', metavar="PATH",
                        help="excel file (output)")

    parser.add_argument('--delimiter', '-d', metavar="STRING",
                        choices=['\t', ',', ' ', ';'], default="\t",
                        help="delimiter in input file)")
    
    parser.add_argument('--engine', '-e', metavar="STRING",
                        choices=['openpyxl', 'xlsxwrite'], default="openpyxl",
                        help="write engine to use, ‘openpyxl’ or  ‘xlsxwriter’")

    return parser

def main(argv):

    parser = make_parser()
    args = parser.parse_args(argv)
    
    app = App(args=args, logger=a_logger('main', level='INFO'))

    app.run()
    
if __name__ == '__main__':
    main(sys.argv[1:])

