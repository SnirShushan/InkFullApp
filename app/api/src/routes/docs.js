import { Router } from 'express';
import swaggerUi from 'swagger-ui-express';
import YAML from 'yamljs';
import path from 'path';
import { fileURLToPath } from 'url';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const openapi = YAML.load(path.join(__dirname, '../../openapi.yaml'));

export const docsRouter = Router();

docsRouter.get('/openapi.json', (_req, res) => {
  res.json(openapi);
});

docsRouter.use(
  '/docs',
  swaggerUi.serve,
  swaggerUi.setup(openapi, {
    customSiteTitle: 'Ink API Docs',
    explorer: true,
  })
);
