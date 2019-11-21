# -*- encoding:utf-8 -*-

import os
import re

# 配置参数

root_src_dir = '.'  # 代码目录名
ignore_dirs = ['test']  # 要忽略的目录（目录名完全匹配）
rules = [
    # Android
    # {
    #     'suffix': '.java',
    #     'new_comment': 'comment_for_java.txt',
    #     'old_comment': 'comment_for_java.txt',
    #     'ignore_files': []  # 要忽略的文件名（文件名完整匹配）
    # },
    # {
    #     'suffix': '.xml',
    #     'new_comment': 'comment_for_xml.txt',
    #     'old_comment': 'comment_for_xml.txt',
    #     'keep_on_top_lines': [re.compile(r'.*<\?xml version="1\.0".*')]  # 要保证在文件前面的行（注释将加在这些行之后）（正则）
    # },
    # iOS
    {
        'suffix': '.h',
        'new_comment': 'new_license_content.txt',  # 要更新的 license 文件
        'old_comment': 'old_license_content.txt',  # 老的的 license 文件，如果文件没有更新，那么内容要保持跟新文件一样
        'delete_lines': [re.compile(r'.*//.*Copyright.*All rights reserved.*')]  # 要从源文件中删除的行（正则）
        # 'ignore_files': []  # 要忽略的文件名（文件名完整匹配）
    },
    {
        'suffix': '.m',
        'new_comment': 'new_license_content.txt',
        'old_comment': 'old_license_content.txt',
        'delete_lines': [re.compile(r'.*//.*Copyright.*All rights reserved.*')]  # 要从源文件中删除的行（正则）
        # 'ignore_files': []  # 要忽略的文件名（文件名完整匹配）
    },
]


# 全局变量

delete_files = []


def is_match_anyone_dir(path, dir_list):
    for d in dir_list:
        if "/{dir}/".format(dir=d) in path:
            return True
    return False


def is_match_anyone_str(filename, str_list):
    for s in str_list:
        if filename == s:
            return True
    return False


def is_match_anyone_regex(line, regex_list):
    for regex in regex_list:
        if regex.match(line):
            return True
    return False


def find_file(start, suffix, ignore_dirs, ignore_files):
    list = []
    for relpath, dirs, files in os.walk(start):
        for filename in files:
            if filename.endswith(suffix):
                full_file_name = os.path.join(relpath, filename)
                if not is_match_anyone_dir(full_file_name, ignore_dirs) and not is_match_anyone_str(filename, ignore_files):
                    list.append(full_file_name)
    return list


def add_comment(rule):
    print('processing with {rule}'.format(rule=rule))

    new_comment_filename = rule['new_comment']
    old_comment_filename = rule['old_comment']
    file_suffix = rule['suffix']
    ignore_files = rule.get('ignore_files', [])
    keep_on_top_lines = rule.get('keep_on_top_lines', [])
    delete_lines = rule.get('delete_lines', [])

    delete_count = 0

    with open(new_comment_filename, 'r', encoding = "utf-8") as f:
        new_comment_content = f.read()

    with open(old_comment_filename, 'r', encoding = "utf-8") as f:
        old_comment_lines = f.readlines()

    old_comment_lines_count = len(old_comment_lines)

    files = find_file(root_src_dir, file_suffix, ignore_dirs, ignore_files)

    for file in files:

        with open(file, 'r', encoding = "utf-8") as f:
            src_lines = f.readlines()

        with open(file, 'w', encoding = "utf-8") as f:
            has_written_comments = False
            is_update_license = False
            line_index = 0

            for line in src_lines:

                is_line_exist = False

                # 这一行是否存在久的文件中
                for old_comment_line in old_comment_lines:
                    if line == old_comment_line:
                        is_line_exist = True
                        break

                # 如果存在则不写进去
                if is_line_exist and len(line.strip()) > 0:
                    line_index += 1
                    delete_count += 1
                    if line_index <= old_comment_lines_count:
                        is_update_license = True
                        continue

                # 是否正则删除
                if is_match_anyone_regex(line, delete_lines):
                    print('ignore line: {line}'.format(line=line))
                    continue

                if not has_written_comments:
                    if is_match_anyone_regex(line, keep_on_top_lines):
                        f.write(line)
                    else:
                        f.writelines(new_comment_content)
                        has_written_comments = True
                        f.write(line)

                else:
                    f.write(line)

            if delete_count != 0 and delete_count != old_comment_lines_count:
                delete_files.append(file)

            delete_count = 0

            if is_update_license:
                print('processing with {file} ({flag})'.format(file=file, flag='update license'))
            else:
                print('processing with {file} ({flag})'.format(file=file, flag='add license'))


if __name__ == '__main__':
    for rule in rules:
        add_comment(rule)
    if len(delete_files) > 0:
        print('==================== 以下文件可能更新遇到问题，建议检查 ====================')
        for delete_file in delete_files:
            print(delete_file)
        print('==================== 以上文件可能更新遇到问题，建议检查 ====================')
        delete_files = []
