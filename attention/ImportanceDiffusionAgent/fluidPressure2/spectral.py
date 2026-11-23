from __future__ import annotations

import numpy as np


def _symbols(n: int) -> tuple[np.ndarray, np.ndarray, np.ndarray]:
    # One grid cell is one numerical length unit.  This matches the finite-
    # volume advection step and avoids injecting an unmodelled n² scale factor.
    freq = np.fft.fftfreq(n, d=1.0)
    s = np.sin(2.0 * np.pi * freq)         
    sy, sx = np.meshgrid(s, s, indexing="ij")
    return sx, sy, -(sx * sx + sy * sy)


def gradient(a: np.ndarray) -> tuple[np.ndarray, np.ndarray]:
    kx, ky, _ = _symbols(a.shape[0])
    ah = np.fft.fft2(a)
    return np.fft.ifft2(1j * kx * ah).real, np.fft.ifft2(1j * ky * ah).real


def sobolev_gradient(a: np.ndarray, mu: float = 0.0) -> tuple[np.ndarray, np.ndarray]:
    """Sobolev-regularized gradient: (I - mu * Δ)^(-1) ∇ a."""
    kx, ky, lap = _symbols(a.shape[0])
    ah = np.fft.fft2(a)
    denom = 1.0 - mu * lap if mu > 0.0 else 1.0
    return np.fft.ifft2(1j * kx * ah / denom).real, np.fft.ifft2(1j * ky * ah / denom).real


def divergence(u: tuple[np.ndarray, np.ndarray]) -> np.ndarray:
    ux, uy = u
    kx, ky, _ = _symbols(ux.shape[0])
    return np.fft.ifft2(1j * kx * np.fft.fft2(ux) + 1j * ky * np.fft.fft2(uy)).real


def vorticity(u: tuple[np.ndarray, np.ndarray]) -> np.ndarray:
    r"""Curl of velocity field: omega = \partial_x u_y - \partial_y u_x."""
    ux, uy = u
    kx, ky, _ = _symbols(ux.shape[0])
    return np.fft.ifft2(1j * kx * np.fft.fft2(uy) - 1j * ky * np.fft.fft2(ux)).real


def laplacian(a: np.ndarray) -> np.ndarray:
    _, _, symbol = _symbols(a.shape[0])
    return np.fft.ifft2(symbol * np.fft.fft2(a)).real


def heat_step(a: np.ndarray, nu: float, dt: float) -> np.ndarray:
    _, _, symbol = _symbols(a.shape[0])
    return np.fft.ifft2(np.fft.fft2(a) * np.exp(nu * dt * symbol)).real


def leray_project(u: tuple[np.ndarray, np.ndarray]) -> tuple[tuple[np.ndarray, np.ndarray], np.ndarray]:
    """Return P(u) and p, where u - grad(p) is divergence free."""
    ux, uy = u
    kx, ky, lap = _symbols(ux.shape[0])
    div_hat = 1j * kx * np.fft.fft2(ux) + 1j * ky * np.fft.fft2(uy)
    p_hat = np.zeros_like(div_hat)
    mask = lap != 0.0
    p_hat[mask] = div_hat[mask] / lap[mask]
    pressure = np.fft.ifft2(p_hat).real
    px = np.fft.ifft2(1j * kx * p_hat).real
    py = np.fft.ifft2(1j * ky * p_hat).real
    return (ux - px, uy - py), pressure
