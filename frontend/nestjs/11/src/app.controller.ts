import { Controller, Get, Render, Res } from '@nestjs/common';
import { AppService } from './app.service';
import type { Response } from 'express';
import { join } from 'path';
import { ConfigService } from '@nestjs/config';

@Controller()
export class AppController {
  constructor(
    private readonly appService: AppService,
    private readonly configService: ConfigService,
  ) {}

  @Get()
  @Render('index')
  root() {
    return {
      backendApiUrl: this.configService.get<string>('BACKEND_API_URL'),
    };
  }

  @Get('todo')
  getTodoApp(@Res() res: Response) {
    return res.sendFile(join(process.cwd(), 'public', 'index.html'));
  }
}
