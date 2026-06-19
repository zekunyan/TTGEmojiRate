import { createRequire } from "node:module";
import { mkdir } from "node:fs/promises";
import path from "node:path";
import { fileURLToPath, pathToFileURL } from "node:url";

const require = createRequire(import.meta.url);
const { chromium } = require("playwright");

const repoRoot = path.resolve(path.dirname(fileURLToPath(import.meta.url)), "..");

const assets = [
  {
    html: "Resources/promo_poster.html",
    output: "Resources/promo_poster.png",
    selector: "#asset",
    width: 1920,
    height: 1080,
  },
  {
    html: "Resources/quick_start_create.html",
    output: "Resources/quick_start_create.png",
    selector: "#asset",
    width: 1440,
    height: 900,
  },
  {
    html: "Resources/quick_start_configure.html",
    output: "Resources/quick_start_configure.png",
    selector: "#asset",
    width: 1440,
    height: 900,
  },
  {
    html: "Resources/quick_start_custom_paths.html",
    output: "Resources/quick_start_custom_paths.png",
    selector: "#asset",
    width: 1440,
    height: 900,
  },
];

async function waitForStableAssets(page) {
  await page.evaluate(async () => {
    if (document.fonts?.ready) {
      await document.fonts.ready;
    }

    await Promise.all(
      Array.from(document.images).map((image) => {
        if (image.complete && image.naturalWidth > 0) {
          return Promise.resolve();
        }
        return image.decode().catch(() => {});
      }),
    );
  });
}

const browser = await chromium.launch({
  headless: true,
  executablePath: process.env.CHROME_PATH || undefined,
});

try {
  for (const asset of assets) {
    const page = await browser.newPage({
      viewport: { width: asset.width, height: asset.height },
      deviceScaleFactor: 2,
    });

    const htmlPath = path.join(repoRoot, asset.html);
    await page.goto(pathToFileURL(htmlPath).href, { waitUntil: "load" });
    await waitForStableAssets(page);

    const target = await page.$(asset.selector);
    if (!target) {
      throw new Error(`Missing ${asset.selector} in ${asset.html}`);
    }

    const outputPath = path.join(repoRoot, asset.output);
    await mkdir(path.dirname(outputPath), { recursive: true });
    await target.screenshot({ path: outputPath, type: "png" });
    await page.close();

    console.log(`Rendered ${asset.output}`);
  }
} finally {
  await browser.close();
}
