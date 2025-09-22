import { Controller, Get, Res } from '@nestjs/common';
import { AppService } from './app.service';
import type { Response } from 'express';
import { join } from 'path';

@Controller()
export class AppController {
  constructor(private readonly appService: AppService) {}

  @Get()
  getHello(): string {
    return this.appService.getHello();
  }

  @Get('todo')
  getTodoApp(@Res() res: Response) {
    return res.sendFile(join(process.cwd(), 'public', 'index.html'));
  }
}
