Mat_Oak = [0.65, 0.5, 0.4];
Mat_Pine = [0.85, 0.7, 0.45];
Mat_Birch = [0.9, 0.8, 0.6];
Mat_FiberBoard = [0.7, 0.67, 0.6];
Mat_BlackPaint = [0.2, 0.2, 0.2];
Mat_Iron = [0.36, 0.33, 0.33];
Mat_Steel = [0.65, 0.67, 0.72];
Mat_Stainless = [0.45, 0.43, 0.5];
Mat_Aluminium = [0.77, 0.77, 0.8];
Mat_Brass = [0.88, 0.78, 0.5];
Mat_Transparent = [1, 1, 1, 0.2];

Mat_Chrome = Mat_Steel;

Mat_Plastic = Mat_Pine;

module material(mat)
{
    color(mat)
    children();
}
