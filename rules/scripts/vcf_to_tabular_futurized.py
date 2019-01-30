# -*- coding: utf-8 -*-
#!usr/bin/python
"""
Copyright (c) 2012, 2013 The PyPedia Project, http://www.pypedia.com
<br>All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

# Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
# Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution. 

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR
ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

http://www.opensource.org/licenses/BSD-2-Clause

Original code from:
http://www.pypedia.com/index.php/Convert_VCF_file_to_TAB_user_Kantale
Retrieve date: Wed, 25 Sep 2013 11:28:29 +0300

Convert a VCF (http://vcftools.sourceforge.net/specs.html) file to a tabular format.

Example:
<source lang="py">
returnedFromVCFConvertionFunction = Convert_VCF_file_to_TAB_user_Kantale(
    inputFilename=VCFFilename,
    printHeader=False,
    outputFilename=tabFilename,
    expandInfo=True,
    expandSample=True,
    printFormat=False,
    functionsToApplyToFields = {"POS": lambda x:x + '\t' + x}, #We want to export a ANNOVAR compatible file
    subtituteHeaderNames = [("REF","REF2"), ("ID","REF"), ("ALT","ALT2"), ("REF2","ALT"), ("ALT2","ID")],
    verbose=True
)

</source>

"""
from __future__ import print_function

from builtins import str
import optparse

def Convert_VCF_file_to_TAB_user_Kantale(
        inputFilename = None,
        printHeader=False,
        outputFilename=False,
        expandInfo=False,
        expandSample=False,
        printFormat = False,
        functionsToApplyToFields=None,
        subtituteHeaderNames=None,
        verbose=False
        ):
    """ """
    #return dictionay with various statistics. To be extended..
    ret = {}
    ret["warnings"] = []

    inputFile = open(inputFilename)

    doubleLabelMessagePrinted = False

    if expandInfo or expandSample:
        if verbose:
            print("Finding info and sample fields")
        parsedComments = False
        infoColumn = None
        infoFields = set()
        sampleColumn = None
        sampleFields = set()
        lineCounter = 0
        while True:
            line = inputFile.readline()
            if line == "":
                break
            lineCounter += 1

            if verbose:
                if lineCounter % 10000 == 0:
                    print("Lines parsed: ", lineCounter)

            lineSplitted = line.replace("\n", "").split()

            if not parsedComments:
                if lineSplitted[0] != "#CHROM":
                    continue
                else:
                    parsedComments = True
                    infoColumn = lineSplitted.index("INFO")
                    sampleColumn = lineSplitted.index("FORMAT")
                    continue

            infoFields   = infoFields   | set([x.split('=')[0] for x in lineSplitted[infoColumn].split(';')])
            sampleFields = sampleFields | set(lineSplitted[sampleColumn].split(':'))
        if verbose:
            print("Done finding info and sample fields")
        infoFields = list(infoFields)
        infoFields.sort()
        # Move fields to the end
        to_the_end = ['AC', 'MQ', 'QD', 'DP']
        for value in to_the_end:
            infoFields.append(infoFields.pop(infoFields.index(value)))
        sampleFields = list(sampleFields)
        inputFile.close()
        inputFile = open(inputFilename)

    headerSplitted = None

    if outputFilename:
        outputFile = open(outputFilename, "w")
    headerPrinted = False
    totalLines = lineCounter
    lineCounter = 0

    while True:
        line = inputFile.readline()
        if line == "":
            break

        if line[0] == "#" and line[1] == "#":
            continue
        lineCounter += 1

        if verbose:
            if lineCounter % 10000 == 0:
                print("Lines parsed: " + str(lineCounter) + "/" + str(totalLines))

        lineSplitted = line.replace("\n", "").split("\t")

        if not headerSplitted:
            headerSplitted = list(lineSplitted)
            headerToPrint = lineSplitted
            continue

        toPrint = {}

        header_format = None
        reference = None
        alternative = None

        for index, headerValue in enumerate(headerSplitted):
            if headerValue.strip() == "":
                continue

            if headerValue == "#CHROM":
                toPrint["#CHROM"] = lineSplitted[index]
            elif headerValue == "POS":
                toPrint["POS"] = lineSplitted[index]
            elif headerValue == "ID":
                toPrint["ID"] = "." if lineSplitted[index] == "." else lineSplitted[index]
            elif headerValue == "REF":
                reference = lineSplitted[index]
                toPrint["REF"] = reference
            elif headerValue == "ALT":
                alternative = lineSplitted[index]
                toPrint["ALT"] = alternative
            elif headerValue == "QUAL":
                toPrint["QUAL"] = lineSplitted[index]
            elif headerValue == "FILTER":
                toPrint["FILTER"] = lineSplitted[index]
            elif headerValue == "INFO":
                if not expandInfo:
                    toPrint["INFO"] = lineSplitted[index]
                else:
                    for infoField in lineSplitted[index].split(';'):
                        infoFieldSplitted = infoField.split('=')
                        #if len(infoFieldSplitted) == 1: toPrint[infoFieldSplitted[0]] = ""
                        if len(infoFieldSplitted) == 1:
                            toPrint[infoFieldSplitted[0]] = 'TRUE'
                        else:
                            toPrint[infoFieldSplitted[0]] = infoFieldSplitted[1]

                    if not headerPrinted:
                        headerToPrint.insert(headerToPrint.index("INFO"), infoFields)
                        headerToPrint.remove("INFO")

            elif headerValue == "FORMAT":
                header_format = lineSplitted[index]
                if printFormat:
                    toPrint["FORMAT"] = header_format
                else:
                    if not headerPrinted:
                        headerToPrint.remove("FORMAT")
            else:
                #We suggest that this is a sample
                if not expandSample:
                    toPrint[headerValue] = lineSplitted[index]
                else:
                    formatSplitted = header_format.split(':')
                    sampleSplitted = lineSplitted[index].split(':')

                    # Replace FORMAT NAMES to avoid duplicated entries
                    # by appending the sample name
                    for i, p in enumerate(formatSplitted):
                        formatSplitted[i] = p + '_' + headerValue

                    for formatIndex, formatValue in enumerate(formatSplitted):
                        #if formatValue == "GT":
                        # Genotype field
                        if formatValue.startswith('GT'):
                            if '/' in sampleSplitted[formatIndex] or True: #This check is only there for future developement.
                                if '/' in sampleSplitted[formatIndex]:
                                    GTSplitted = sampleSplitted[formatIndex].split('/')
                                elif '|' in sampleSplitted[formatIndex]:
                                    GTSplitted = sampleSplitted[formatIndex].split('|')
                                else:
                                    raise Exception("Genotype delimiter not recognized")
                                Alleles = []
                                for GT in GTSplitted:
                                    if GT == ".":
                                        Genotype = "."
                                    elif GT == "0":
                                        Genotype = reference
                                    else:
                                        Genotype = alternative[int(GT)-1]
                                    Alleles += [Genotype]
                                #if len(Alleles) == 2: toPrint["GT"] = Alleles[0] + "/" + Alleles[1]
                                #elif len(Alleles) == 1: toPrint["GT"] = Alleles[0] + "/" + Alleles[0]
                                if len(Alleles) == 2:
                                    toPrint[formatValue] = Alleles[0] + "/" + Alleles[1]
                                elif len(Alleles) == 1:
                                    toPrint[formatValue] = Alleles[0] + "/" + Alleles[0]
                                else:
                                    raise Exception("Format error..")
                            else:
                                raise Exception("Not implemented..") #Please do someone.. (right now unreachable code)
                        else:
                            if formatValue in toPrint:
                                #This is indicative that something wrong happened.
                                if not doubleLabelMessagePrinted:
                                    warningStr = "WARNING: field " + formatValue + " exists twice. This message is printed only once"
                                    ret["warnings"] += [warningStr]
                                    print(warningStr)

                                    doubleLabelMessagePrinted = True
                                toPrint[formatValue+"2"] = sampleSplitted[formatIndex]
                            else:
                                # If missing, add '.'
                                if sampleSplitted[0] == './.' or sampleSplitted[0] == '.|.':
                                    toPrint[formatValue] = '.'
                                else:
                                    toPrint[formatValue] = sampleSplitted[formatIndex]
                    if not headerPrinted:
                        # Append sample name to sampleFields
                        sampleFieldsWithName = [el + '_' + headerValue for el in sampleFields]
                        headerToPrint.insert(index, sampleFieldsWithName)
                        headerToPrint.remove(headerValue)

        if not headerPrinted:
            headerPrinted = True
            headerToPrint = flatList(headerToPrint) #Make the list flat

            if subtituteHeaderNames:
                for substituteHeaderName in subtituteHeaderNames:
                    headerToPrint[headerToPrint.index(substituteHeaderName[0])] = substituteHeaderName[1]

            ret["header"] = headerToPrint
            if printHeader:
                headerToPrintStr = str.join('\t', headerToPrint)
                if outputFilename:
                    outputFile.write(headerToPrintStr + "\n")
                else:
                    print(headerToPrintStr)

        toPrintNormalized = []
        alreadyPrinted = []

        for fieldToPrint in headerToPrint:

            if fieldToPrint.strip() == "":
                continue

            if fieldToPrint in alreadyPrinted:
                fieldToPrint = fieldToPrint + "2"

            fieldAppliedFunction = toPrint[fieldToPrint] if fieldToPrint in toPrint else ""

            if functionsToApplyToFields:
                if fieldToPrint in functionsToApplyToFields:
                    fieldAppliedFunction = functionsToApplyToFields[fieldToPrint](fieldAppliedFunction)

            toPrintNormalized += [fieldAppliedFunction]

            alreadyPrinted += [fieldToPrint]
        toPrintStr = str.join('\t', toPrintNormalized)
        if outputFilename:
            outputFile.write(toPrintStr + "\n")
        else:
            print(toPrintStr)


    inputFile.close()
    if outputFilename:
        outputFile.close()

    return ret


def flatList(aList):
    """ """
    ret = []

    for x in aList:
        if type(x).__name__ != "list":
            ret.extend([x])
        else:
            ret.extend(flatList(x))

    return ret


def __main__():
    usage = "usage: %prog [options] input.vcf output.tab"
    parser = optparse.OptionParser(usage)
    parser.add_option('--no-header', dest='print_header', action='store_false', default=True, help='Do not print HEADER')
    parser.add_option('--do-not-split-info', dest='split_info', action='store_false', default=True, help='Do not expand INFO field')
    parser.add_option('--do-not-split-sample', dest='split_sample',  action='store_false', default=True, help='Do not expand SAMPLE field')
    parser.add_option('--print-format', dest='print_format',  action='store_true', default=False, help='Print FORMAT field')
    parser.add_option('--functions', dest='functions', default=None, help='Functions to apply to fields:\t\t\t\t # We want to export a ANNOVAR compatible file\t\t\t\t{"POS": lambda x:x + \'\\t\' + x}')
    parser.add_option('--new-header', dest='new_header', default=None, help='Substitute header names')
    parser.add_option('--quiet', dest='verbose', action='store_false', default=True, help='Quiet')
    (options, args) = parser.parse_args()
    if len(args) != 2:
        parser.error('Wrong number of arguments')

    returned = Convert_VCF_file_to_TAB_user_Kantale(
        inputFilename=args[0],
        outputFilename=args[1],
        printHeader=options.print_header,
        expandInfo=options.split_info,
        expandSample=options.split_sample,
        printFormat = options.print_format,
        functionsToApplyToFields=options.functions,
        subtituteHeaderNames=options.new_header,
        verbose=options.verbose
    )
    if returned:
        print('Method returned:')
        print(str(returned))


if __name__ == '__main__':
    __main__()
