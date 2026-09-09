import { Router } from 'express';
import { legalIndexHtml, privacyHtml, termsHtml } from '../legal/pages.js';

export const legalRouter = Router();

legalRouter.get(['/legal', '/legal/'], (_req, res) => {
  res.type('html').send(legalIndexHtml());
});

legalRouter.get(['/privacy', '/privacy/', '/legal/privacy'], (_req, res) => {
  res.type('html').send(privacyHtml());
});

legalRouter.get(['/terms', '/terms/', '/legal/terms'], (_req, res) => {
  res.type('html').send(termsHtml());
});
