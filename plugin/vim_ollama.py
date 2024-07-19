"""
Vim adapter for ollama
"""
# Resolve libraries
import os
import sys
import vim
print(sys.executable)
current_dir = vim.eval('s:python_dir')
libs_path = f'{current_dir}/.venv/lib/python3.11/site-packages'
sys.path.append(libs_path)


# pylint: disable=wrong-import-position
import asyncio
from ollama import AsyncClient
from sqlmodel import SQLModel


class Config(SQLModel):
    """Configuration settings for the ollama adapter"""
    ollama_host: str = 'http://localhost:11434'
    ollama_model: str = 'codellama:13b'


class OllamaAdapter:
    """Ollama adapater implementation"""

    def __init__(self, cfg: Config):
        self.cfg = cfg
        self.client = AsyncClient(host=cfg.ollama_host)

    async def chat(self):
        """Chat with a model"""
        message = {'role': 'user', 'content': 'Why is the sky blue?'}
        async for part in await self.client.chat(
                model=self.cfg.ollama_model, messages=[message], stream=True):
            print(part['message']['content'], end='', flush=True)

    def load_buffer_contents(self):
        """Loads the current buffer contents as a string"""
        lines = vim.eval('getline(1, "$")')
        print('The lines: ', lines)


if __name__ == '__main__':
    adapter = OllamaAdapter(Config())
    asyncio.run(adapter.chat())
