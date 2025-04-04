// ---------------------------------------------------------------------------
// <copyright file="Common.cs" company="John Merryweather Cooper">
//     Copyright © 2022, 2023, 2024, 2025, John Merryweather Cooper. All Rights Reserved.
//
//     Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following
//     conditions are met:
//
//     1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
//
//     2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following
//     disclaimer in the documentation and/or other materials provided with the distribution.
//
//     3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products
//     derived from this software without specific prior written permission.
//
//     THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING,
//     BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO
//     EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
//     CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
//     PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR
//     TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
//     POSSIBILITY OF SUCH DAMAGE.
// </copyright>
// <author>
// John Merryweather Cooper
// </author>
// <date>
// Created:  2025-4-3
// </date>
// <summary>
// This file "Common.cs" is part of "Octopus.Client.Cmdlet".
// </summary>
// <remarks>
// description
// </remarks>
// ---------------------------------------------------------------------------

namespace Octopus.Client.Cmdlet
{
    using System;
    using System.Collections.Generic;
    using System.IO;
    using System.Management.Automation;
    using System.Runtime.CompilerServices;

    public static class Common
    {
        #region Public Methods

        /// <summary>
        /// Formats a PowerShell error id <see cref="string" />.
        /// </summary>
        /// <param name="caller">
        /// Specifies the calling method. If not provided, the runtime will attempt to extract it.
        /// </param>
        /// <param name="exception">
        /// Specifies the <see cref="Exception" />. If null, 'Unknown' will be used.
        /// </param>
        /// <param name="position">
        /// Specifies the line number of the caller. If zero, the runtime will attempt to extract it.
        /// </param>
        /// <returns>
        /// Returns a formatted <see cref="string" /> suitable for use as a PowerShell error id.
        /// </returns>
        public static string FormatErrorId([CallerMemberName] string? caller = null, Exception? exception = null, [CallerLineNumber] int position = 0)
        {
            if (string.IsNullOrWhiteSpace(caller) && exception == null)
            {
                return $"PS-Unknown-{position}";
            }
            else if (exception == null)
            {
                return $"{caller}-Unknown-{position}";
            }
            else
            {
                return $"{caller}-{exception.GetType().Name}-{position}";
            }
        }

        /// <summary>
        /// </summary>
        /// <typeparam name="T">
        /// </typeparam>
        /// <param name="instance">
        /// </param>
        /// <param name="parameter">
        /// </param>
        /// <param name="value">
        /// </param>
        /// <param name="test">
        /// </param>
        /// <param name="message">
        /// </param>
        public static void ThrowIfFalse<T>(this PSCmdlet instance, string parameter, T value, Predicate<T> test, string? message)
        {
            if (!test.Invoke(value))
            {
                var exception = new ArgumentException(message, parameter);
                instance.WriteFatal(exception, ErrorCategory.InvalidArgument, value, null, 0);
            }
        }

        /// <summary>
        /// </summary>
        /// <typeparam name="T">
        /// </typeparam>
        /// <param name="instance">
        /// </param>
        /// <param name="set">
        /// </param>
        /// <param name="value">
        /// </param>
        /// <param name="message">
        /// </param>
        public static void ThrowIfNotContained<T>(this PSCmdlet instance, ISet<T> set, T value, string? message)
            where T : struct
        {
            if (!set.Contains(value))
            {
                var exception = new InvalidDataException(message);
                instance.WriteFatal(exception, ErrorCategory.InvalidData, value, null, 0);
            }
        }

        /// <summary>
        /// </summary>
        /// <param name="instance">
        /// </param>
        /// <param name="enumType">
        /// </param>
        /// <param name="value">
        /// </param>
        /// <param name="message">
        /// </param>
        public static void ThrowIfNotContained(this PSCmdlet instance, Type enumType, string value, string? message)
        {
            instance.ThrowIfFalse<Type>(nameof(enumType), enumType, t => t.IsEnum, $"Type '{enumType.Name}' is not an 'Enum'");
            instance.ThrowIfFalse(nameof(value), value, v => Enum.IsDefined(enumType, v), message ?? $"String Value '{value}' is not defined in '{enumType.Name}'");
        }

        /// <summary>
        /// </summary>
        /// <param name="instance">
        /// </param>
        /// <param name="enumType">
        /// </param>
        /// <param name="value">
        /// </param>
        /// <param name="message">
        /// </param>
        public static void ThrowIfNotContained(this PSCmdlet instance, Type enumType, int value, string? message)
        {
            instance.ThrowIfFalse<Type>(nameof(enumType), enumType, t => t.IsEnum, $"Type '{enumType.Name}' is not an 'Enum'");
            instance.ThrowIfFalse(nameof(value), value, v => Enum.IsDefined(enumType, v), message ?? $"Integer Value '{value}' is not defined in '{enumType.Name}'");
        }

        /// <summary>
        /// </summary>
        /// <param name="instance">
        /// </param>
        /// <param name="path">
        /// </param>
        /// <param name="message">
        /// </param>
        public static void ThrowIfNotDirectory(this PSCmdlet instance, FileSystemInfo path, string? message)
        {
            if (!path.Attributes.HasFlag(FileAttributes.Directory))
            {
                var exception = new DirectoryNotFoundException(message);
                instance.WriteFatal(exception, ErrorCategory.InvalidType, path, null, 0);
            }
        }

        /// <summary>
        /// </summary>
        /// <param name="instance">
        /// </param>
        /// <param name="path">
        /// </param>
        /// <param name="message">
        /// </param>
        public static void ThrowIfNotExists(this PSCmdlet instance, DirectoryInfo path, string? message)
        {
            if (!path.Exists)
            {
                var exception = new DirectoryNotFoundException(message);
                instance.WriteFatal(exception, ErrorCategory.ObjectNotFound, path, null, 0);
            }
        }

        /// <summary>
        /// </summary>
        /// <param name="instance">
        /// </param>
        /// <param name="path">
        /// </param>
        /// <param name="message">
        /// </param>
        public static void ThrowIfNotExists(this PSCmdlet instance, FileInfo path, string? message)
        {
            if (!path.Exists)
            {
                var exception = new FileNotFoundException(message, path.FullName);
                instance.WriteFatal(exception, ErrorCategory.ObjectNotFound, path, null, 0);
            }
        }

        /// <summary>
        /// </summary>
        /// <param name="instance">
        /// </param>
        /// <param name="path">
        /// </param>
        /// <param name="message">
        /// </param>
        public static void ThrowIfNotFile(this PSCmdlet instance, FileSystemInfo path, string? message)
        {
            if (path.Attributes.HasFlag(FileAttributes.Directory) ^ path.Attributes.HasFlag(FileAttributes.Device) ^ path.Attributes.HasFlag(FileAttributes.ReparsePoint))
            {
                var exception = new FileNotFoundException(message);
                instance.WriteFatal(exception, ErrorCategory.InvalidType, path, null, 0);
            }
        }

        /// <summary>
        /// </summary>
        /// <param name="instance">
        /// </param>
        /// <param name="parameter">
        /// </param>
        /// <param name="value">
        /// </param>
        /// <param name="message">
        /// </param>
        public static void ThrowIfNull(this PSCmdlet instance, string parameter, object? value, string? message)
        {
            if (value == null)
            {
                var exception = new ArgumentNullException(parameter, message);
                instance.WriteFatal(exception, ErrorCategory.InvalidArgument, value, null, 0);
            }
        }

        /// <summary>
        /// </summary>
        /// <param name="instance">
        /// </param>
        /// <param name="parameter">
        /// </param>
        /// <param name="value">
        /// </param>
        /// <param name="message">
        /// </param>
        public static void ThrowIfNullOrEmpty(this PSCmdlet instance, string parameter, string? value, string? message)
        {
            if (string.IsNullOrEmpty(value))
            {
                var exception = new ArgumentNullException(parameter, message);
                instance.WriteFatal(exception, ErrorCategory.InvalidArgument, value, null, 0);
            }
        }

        /// <summary>
        /// </summary>
        /// <param name="instance">
        /// </param>
        /// <param name="parameter">
        /// </param>
        /// <param name="value">
        /// </param>
        /// <param name="message">
        /// </param>
        public static void ThrowIfNullOrWhiteSpace(this PSCmdlet instance, string parameter, string? value, string? message)
        {
            if (string.IsNullOrWhiteSpace(value))
            {
                var exception = new ArgumentNullException(parameter, message);
                instance.WriteFatal(exception, ErrorCategory.InvalidArgument, value, null, 0);
            }
        }

        /// <summary>
        /// </summary>
        /// <typeparam name="T">
        /// </typeparam>
        /// <param name="instance">
        /// </param>
        /// <param name="parameter">
        /// </param>
        /// <param name="value">
        /// </param>
        /// <param name="outOfRange">
        /// </param>
        /// <param name="message">
        /// </param>
        public static void ThrowIfOutOfRange<T>(this PSCmdlet instance, string parameter, T value, Predicate<T> outOfRange, string? message)
            where T : IComparable<T>, IEqualityComparer<T>
        {
            if (outOfRange.Invoke(value))
            {
                var exception = new ArgumentOutOfRangeException(parameter, value, message);
                instance.WriteFatal(exception, ErrorCategory.LimitsExceeded, value, null, 0);
            }
        }

        /// <summary>
        /// </summary>
        /// <typeparam name="T">
        /// </typeparam>
        /// <param name="instance">
        /// </param>
        /// <param name="parameter">
        /// </param>
        /// <param name="value">
        /// </param>
        /// <param name="test">
        /// </param>
        /// <param name="message">
        /// </param>
        public static void ThrowIfTrue<T>(this PSCmdlet instance, string parameter, T value, Predicate<T> test, string? message)
        {
            if (test.Invoke(value))
            {
                var exception = new ArgumentException(message, parameter);
                instance.WriteFatal(exception, ErrorCategory.InvalidArgument, value, null, 0);
            }
        }

        /// <summary>
        /// Extension method to log and throw a terminating error.
        /// </summary>
        /// <param name="instance">
        /// Specifies the <see cref="PSCmdlet" /> instance to extend.
        /// </param>
        /// <param name="message">
        /// Specifies the <see cref="string" /> to initialize <see cref="InvalidOperationException" /> and log as an <see cref="ErrorRecord" />.
        /// </param>
        /// <param name="targetObject">
        /// Specifies the <see cref="object" /> that is the source of the <paramref name="exception" />.
        /// </param>
        /// <param name="caller">
        /// Specifies the calling method. If not provided, the runtime will attempt to extract it.
        /// </param>
        /// <param name="position">
        /// Specifies the line number of the caller. If zero, the runtime will attempt to extract it.
        /// </param>
        public static void WriteError(this PSCmdlet instance, string? message, object? targetObject, [CallerMemberName] string? caller = null, [CallerLineNumber] int position = 0)
        {
            var exception = new InvalidOperationException(message);
            var error = new ErrorRecord(exception, Common.FormatErrorId(caller, exception, position), ErrorCategory.InvalidOperation, targetObject);
            instance.WriteError(error);
        }

        /// <summary>
        /// Extension method to log and throw a terminating error.
        /// </summary>
        /// <param name="instance">
        /// Specifies the <see cref="PSCmdlet" /> instance to extend.
        /// </param>
        /// <param name="exception">
        /// Specifies the <see cref="Exception" /> to log and throw as an <see cref="ErrorRecord" />.
        /// </param>
        /// <param name="category">
        /// Specifies the <see cref="ErrorCategory" /> to build the <see cref="ErrorRecord" /> with.
        /// </param>
        /// <param name="targetObject">
        /// Specifies the <see cref="object" /> that is the source of the <paramref name="exception" />.
        /// </param>
        /// <param name="caller">
        /// Specifies the calling method. If not provided, the runtime will attempt to extract it.
        /// </param>
        /// <param name="position">
        /// Specifies the line number of the caller. If zero, the runtime will attempt to extract it.
        /// </param>
        public static void WriteError(this PSCmdlet instance, Exception exception, ErrorCategory category, object? targetObject, [CallerMemberName] string? caller = null, [CallerLineNumber] int position = 0)
        {
            var error = new ErrorRecord(exception, Common.FormatErrorId(caller, exception, position), category, targetObject);
            instance.WriteError(error);
        }

        /// <summary>
        /// Extension method to log and throw a terminating error.
        /// </summary>
        /// <param name="instance">
        /// Specifies the <see cref="PSCmdlet" /> instance to extend.
        /// </param>
        /// <param name="error">
        /// Specifies the <see cref="ErrorRecord" /> to log and throw.
        /// </param>
        public static void WriteFatal(this PSCmdlet instance, ErrorRecord error)
        {
            instance.WriteError(error);
            instance.ThrowTerminatingError(error);
        }

        /// <summary>
        /// Extension method to log and throw a terminating error.
        /// </summary>
        /// <param name="instance">
        /// Specifies the <see cref="PSCmdlet" /> instance to extend.
        /// </param>
        /// <param name="exception">
        /// Specifies the <see cref="Exception" /> to log and throw as an <see cref="ErrorRecord" />.
        /// </param>
        /// <param name="category">
        /// Specifies the <see cref="ErrorCategory" /> to build the <see cref="ErrorRecord" /> with.
        /// </param>
        /// <param name="targetObject">
        /// Specifies the <see cref="object" /> that is the source of the <paramref name="exception" />.
        /// </param>
        /// <param name="caller">
        /// Specifies the calling method. If not provided, the runtime will attempt to extract it.
        /// </param>
        /// <param name="position">
        /// Specifies the line number of the caller. If zero, the runtime will attempt to extract it.
        /// </param>
        public static void WriteFatal(this PSCmdlet instance, Exception exception, ErrorCategory category, object? targetObject, [CallerMemberName] string? caller = null, [CallerLineNumber] int position = 0)
        {
            var error = new ErrorRecord(exception, Common.FormatErrorId(caller, exception, position), category, targetObject);
            instance.WriteFatal(error);
        }

        #endregion Public Methods
    }
}
