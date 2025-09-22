import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';

async function bootstrap() {
  const app = await NestFactory.create(AppModule);
  
  // Enable CORS
  app.enableCors({
    origin: process.env.CORS_ORIGIN || '*',
    credentials: true,
  });
  
  const port = process.env.PORT || 80;
  const host = '0.0.0.0';
  
  await app.listen(port, host, () => {
    console.log(`Application is running on: http://${host}:${port}`);
  });
}
bootstrap();
