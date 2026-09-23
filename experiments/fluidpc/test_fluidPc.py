"""PC ablation checks; synthetic inputs require no MNIST download."""
import unittest
from unittest.mock import patch

import torch

from fluidPc import (
    Config, DEVICE, FluidPCN, infer_density, make_optimizers,
    train_batch, transport_step,
)


class PCAblationTests(unittest.TestCase):
    def test_without_pc_is_transport_only_and_still_learns(self):
        torch.manual_seed(7)
        cfg = Config(disable_pc=True, infer_steps=3, control_horizon=2)
        model = FluidPCN(cfg).to(DEVICE)
        x = torch.rand(4, 1, 28, 28, device=DEVICE)
        y = torch.tensor([0, 1, 2, 3], device=DEVICE)
        initial = model.random_density(x)
        optimizers = make_optimizers(model, cfg)
        self.assertNotIn('pc', optimizers)
        pc_before = [p.detach().clone() for p in model.pc_local.parameters()]
        flow_before = [p.detach().clone() for p in model.stream_controller.parameters()]
        with patch.object(model, 'pc_prediction', side_effect=AssertionError('PC called')):
            with patch.object(model, 'random_density', return_value=initial.clone()):
                actual, _ = infer_density(model, x, cfg)
            with torch.no_grad():
                expected = initial.clone()
                value = model.value_map(x)
                for step in range(cfg.infer_steps):
                    u = model.velocity(expected, x, value)
                    expected = transport_step(expected, u, step, cfg.infer_steps, cfg)
            torch.testing.assert_close(actual, expected)
            metrics = train_batch(model, optimizers, x, y, cfg)
        self.assertEqual(metrics['pc'], 0.0)
        for before, after in zip(pc_before, model.pc_local.parameters()):
            torch.testing.assert_close(before, after)
            self.assertIsNone(after.grad)
        self.assertTrue(any(not torch.equal(a, b) for a, b in
                            zip(flow_before, model.stream_controller.parameters())))
        self.assertGreaterEqual(actual.min().item(), 0.0)
        torch.testing.assert_close(actual.sum((1, 2, 3)), torch.ones(4, device=DEVICE))

    def test_default_still_runs_and_trains_pc(self):
        cfg = Config(infer_steps=2, control_horizon=1)
        model = FluidPCN(cfg).to(DEVICE)
        optimizers = make_optimizers(model, cfg)
        before = model.pc_local.weight.detach().clone()
        with patch.object(model, 'pc_prediction', wraps=model.pc_prediction) as predictor:
            train_batch(model, optimizers, torch.rand(4, 1, 28, 28),
                        torch.tensor([0, 1, 2, 3]), cfg)
        self.assertEqual(predictor.call_count, cfg.infer_steps + 1)
        self.assertFalse(torch.equal(before, model.pc_local.weight))


if __name__ == '__main__':
    unittest.main()
