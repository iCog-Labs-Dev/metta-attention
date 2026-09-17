import numpy as np

_rng = np.random.default_rng()


def mean(arr):
    return float(np.mean(arr))


def std(arr):
    return round(float(np.std(arr)), 2)


def random_beta(alpha, beta):
    return float(_rng.beta(float(alpha), float(beta)))


def seed_random(seed):
    global _rng
    _rng = np.random.default_rng(int(seed))
