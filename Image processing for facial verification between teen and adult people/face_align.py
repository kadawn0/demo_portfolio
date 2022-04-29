import face_alignment
import collections
import os
import time
import matplotlib.pyplot as plt
import numpy as np
from skimage import io
from PIL import Image
from glob import glob
from math import atan2, degrees


class Point:
    def __init__(self, x_init, y_init):
        self.x = x_init
        self.y = y_init

    def __repr__(self):
        return "".join(["Point(", str(self.x), ",", str(self.y), ")"])


# Determines the angle of a straight line drawn between point one and two.
# The number returned, which is a double in degrees, tells us how much we
# have to rotate a horizontal line clockwise for it to match the line
# between the two points.
# If you prefer to deal with angles using radians instead of degrees,
# just change the last line to: "return atan2(y_diff, x_diff)"
def get_angle_of_line_between_two_points(p1, p2):
    x_diff = p2.x - p1.x
    y_diff = p2.y - p1.y
    return degrees(atan2(y_diff, x_diff))


db_training = 'i1213s1720/training'

fa = face_alignment.FaceAlignment(
    face_alignment.LandmarksType._2D, flip_input=False, device='cpu')

pred_type = collections.namedtuple('prediction_type', ['slice', 'color'])
pred_types = {
    'eye1': pred_type(slice(36, 42), (0.596, 0.875, 0.541, 0.3)),
    'eye2': pred_type(slice(42, 48), (0.596, 0.875, 0.541, 0.3)),
}

if not os.path.exists(f'{db_training}/aligned_faces'):
    os.mkdir(f'{db_training}/aligned_faces')

start_time = time.time()
for path in glob(f'{db_training}/*.jpg'):
    filename = path.split('.')[0].split('/')[-1]

    image = io.imread(path)

    try:
        preds = fa.get_landmarks(image)[-1]

        mass_center_eyes = []
        for pred_type in pred_types.values():
            mass_center = np.mean(preds[pred_type.slice], axis=0)
            mass_center = Point(*mass_center)
            mass_center_eyes.append(mass_center)

        color_image = Image.open(path)
        angle = get_angle_of_line_between_two_points(*mass_center_eyes)

        if not abs(angle) > 15:
            rotated = color_image.rotate(angle)
            rotated.save(f'{db_training}/aligned_faces/{filename}.jpg')
            print(f'{path} se roto en {angle} grados')
        else:
            color_image.save(f'{db_training}/aligned_faces/{filename}.jpg')
            print(f'{path} no se roto, su angulo de rotacion es de {angle} grados')

    except:
        color_image = Image.open(path)
        color_image.save(f'{db_training}/aligned_faces/{filename}.jpg')
        print(f'{path} no se reconocio cara')

end_time = time.time()
print(f'Total time was {end_time - start_time}')
