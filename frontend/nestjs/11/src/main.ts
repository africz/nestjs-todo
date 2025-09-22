import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';
import { join } from 'path';
import { NestExpressApplication } from '@nestjs/platform-express';

async function bootstrap() {
  const app = await NestFactory.create<NestExpressApplication>(AppModule);
  
  // Enable CORS
  app.enableCors({
    origin: process.env.CORS_ORIGIN || '*',
    credentials: true,
  });

  // Serve static files
  app.useStaticAssets(join(__dirname, '..', 'public'));
  
  const port = process.env.PORT || 80;
  const host = '0.0.0.0';
  
  await app.listen(port, host, () => {
    console.log(`Application is running on: http://${host}:${port}`);
    console.log(`Todo app available at: http://${host}:${port}/todo`);
  });
}
bootstrap();
