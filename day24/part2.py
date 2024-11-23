import sympy
from sympy import symbols

x, y, z, vx, vy, vz = symbols("x, y, z, vx, vy, vz", real=True)
t1, t2, t3, t4, t5, t6 = symbols("t1, t2, t3, t4, t5, t6", positive=True)

solution = sympy.solve(
    [
        x + t1 * vx - 297310270744292 - t1 * (-130),
        y + t1 * vy - 292515986537934 - t1 * 46,
        z + t1 * vz - 398367816281800 - t1 * (-342),
        #
        x + t2 * vx - 232876297732390 - t2 * 104,
        y + t2 * vy - 268639840875352 - t2 * 56,
        z + t2 * vz - 277457353569056 - t2 * 8,
        #
        x + t3 * vx - 417792738798400 - t3 * (-82),
        y + t3 * vy - 257428680393360 - t3 * 16,
        z + t3 * vz - 380908169439745 - t3 * (-101),
        #
        x + t4 * vx - 302813003461079 - t4 * (-11),
        y + t4 * vy - 305174023577355 - t4 * (-25),
        z + t4 * vz - 349549524249307 - t4 * (-119)
    ],
    [x, y, z, vx, vy, vz, t1, t2, t3, t4],
    dict=True
)[0]
print(solution[x] + solution[y] + solution[z])