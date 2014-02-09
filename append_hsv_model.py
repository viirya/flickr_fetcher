
import sys
import argparse
import re
import pymongo
import colorsys

from PIL import Image
from numpy import array, random, mean

import utils

def main():
    parser = argparse.ArgumentParser(description = 'Calculating HSV values from images and appending into file.')
    parser.add_argument('-f', help = 'The CSV summary file.')
    parser.add_argument('-e', help = 'The flag to keep common header of files.')
    parser.add_argument('-t', help = 'The temporary path for storing downloaded image.')
    parser.add_argument('-o', help = 'The output file.')

    args = parser.parse_args()
    output = read_data(args)

    if (args.o != None):
        utils.write_file(output, args.o)


def calculat_hsv_model(part_of_data, image_temp_dir):

    content = []
    for line in part_of_data:
        line_fields = line.rsplit(',')
        if (len(line_fields) == 1):
            line_fields = line.rsplit("\t")

        image_url = line_fields[0]
        utils.crawl_image_from_url(image_url, image_temp_dir + '/temp.jpg')
        im = Image.open(image_temp_dir + '/temp.jpg')
        pix = im.load()

        hue = []
        satuation = []
        value = []
        (image_width, image_height) = im.size
        for index_x in range(image_width):
            for index_y in range(image_height):

                pixel = pix[index_x, index_y]

                (red, green, blue, alpha) = (0, 0, 0, 0)

                if len(pixel) == 3:
                    (red, green, blue) = pixel
                elif len(pixel) == 4:
                    (red, green, blue, alpha) = pixel

                red /= float(255)
                green /= float(255)
                blue /= float(255)

                (h, s, v) = colorsys.rgb_to_hsv(red, green, blue)
                hue.append(h)
                satuation.append(s)
                value.append(v)
                #print(str(red) + " " + str(green) + " " + str(blue))
                #print(str(h) + " " + str(s) + " " + str(v))

        mean_hsu = mean(hue)
        mean_satuation = mean(satuation)
        mean_value = mean(value)

        line_fields.append(str(mean_hsu))
        line_fields.append(str(mean_satuation))
        line_fields.append(str(mean_value))

        content.append(",".join(line_fields))
 

    return content


def read_data(args):

    data_sources = []
    header = ''
    if (args.f != None):

        parts = []
        afile = args.f

        part_of_data = utils.load_file(afile)
        
        if args.e != None and args.e == 'y':
            if header == '':
                header = part_of_data[0]
            part_of_data = part_of_data[1:len(part_of_data)]
        
        
        part_of_data = calculat_hsv_model(part_of_data, args.t)
            
        parts.append(part_of_data)
        
        parts = [item for sublist in parts for item in sublist]
        data_sources = array(parts)

    output = []
    if header != '':
        output.append(header)
    for item in data_sources:
        output.append(item)

    return output


if __name__ == "__main__":
    main()

